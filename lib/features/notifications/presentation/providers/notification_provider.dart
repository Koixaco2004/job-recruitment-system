import 'dart:async';
import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:dartz/dartz.dart';
import '../../../../core/network/api_client.dart';
import '../../../auth/data/datasources/auth_local_datasource.dart';
import '../../domain/entities/notification_entity.dart';
import '../../domain/usecases/notification_usecases.dart';
import '../../data/models/notification_model.dart';

class NotificationProvider extends ChangeNotifier {
  final GetNotificationsUseCase getNotificationsUseCase;
  final GetUnreadCountUseCase getUnreadCountUseCase;
  final MarkAsReadUseCase markAsReadUseCase;
  final MarkAllReadUseCase markAllReadUseCase;
  final AuthLocalDataSource authLocalDataSource;
  final ApiClient apiClient;

  NotificationProvider({
    required this.getNotificationsUseCase,
    required this.getUnreadCountUseCase,
    required this.markAsReadUseCase,
    required this.markAllReadUseCase,
    required this.authLocalDataSource,
    required this.apiClient,
  });

  List<NotificationEntity> _notifications = [];
  int _unreadCount = 0;
  bool _isLoading = false;
  String? _errorMessage;
  IO.Socket? _socket;
  bool _isConnected = false;
  
  // Stream for real-time kanban updates
  final _kanbanUpdateController = StreamController<Map<String, dynamic>>.broadcast();
  Stream<Map<String, dynamic>> get kanbanUpdateStream => _kanbanUpdateController.stream;

  List<NotificationEntity> get notifications => _notifications;
  int get unreadCount => _unreadCount;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isConnected => _isConnected;

  // ─── REST API METHODS ──────────────────────────────────────────────────────

  Future<void> fetchNotifications({bool refresh = false}) async {
    if (refresh) {
      _notifications = [];
      notifyListeners();
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final result = await getNotificationsUseCase.execute(
      page: refresh ? 1 : (_notifications.length ~/ 20) + 1,
      limit: 20,
    );

    result.fold(
      (failure) {
        _errorMessage = failure.message;
        _isLoading = false;
        notifyListeners();
      },
      (notifications) {
        if (refresh) {
          _notifications = notifications;
          // Sync unread count when refreshing list
          fetchUnreadCount();
        } else {
          _notifications.addAll(notifications);
        }
        _isLoading = false;
        notifyListeners();
      },
    );
  }

  Future<void> fetchUnreadCount() async {
    final result = await getUnreadCountUseCase.execute();
    result.fold(
      (failure) {
        debugPrint('⚠️ Error fetching unread count: ${failure.message}');
      },
      (count) {
        debugPrint('🔢 Updated Unread Count: $count');
        _unreadCount = count;
        notifyListeners();
      },
    );
  }

  Future<void> markNotificationAsRead(int id) async {
    final result = await markAsReadUseCase.execute(id);
    result.fold(
      (failure) => null,
      (success) {
        if (success) {
          final index = _notifications.indexWhere((n) => n.id == id);
          if (index != -1) {
            final notification = _notifications[index];
            if (!notification.isRead) {
              _notifications[index] = NotificationEntity(
                id: notification.id,
                userId: notification.userId,
                type: notification.type,
                title: notification.title,
                content: notification.content,
                metadata: notification.metadata,
                isRead: true,
                createdAt: notification.createdAt,
                updatedAt: DateTime.now(),
              );
              if (_unreadCount > 0) _unreadCount--;
              notifyListeners();
            }
          }
        }
      },
    );
  }

  Future<void> markAllNotificationsAsRead() async {
    final result = await markAllReadUseCase.execute();
    result.fold(
      (failure) => null,
      (success) {
        if (success) {
          _notifications = _notifications.map((n) {
            return NotificationEntity(
              id: n.id,
              userId: n.userId,
              type: n.type,
              title: n.title,
              content: n.content,
              metadata: n.metadata,
              isRead: true,
              createdAt: n.createdAt,
              updatedAt: DateTime.now(),
            );
          }).toList();
          _unreadCount = 0;
          notifyListeners();
        }
      },
    );
  }

  // ─── SOCKET.IO METHODS ─────────────────────────────────────────────────────

  Future<void> initSocket({bool forceReinit = false}) async {
    if (_socket != null && !forceReinit) return;
    
    if (forceReinit && _socket != null) {
      _socket!.disconnect();
      _socket!.dispose();
      _socket = null;
    }

    final token = await authLocalDataSource.getToken();
    if (token == null) {
      debugPrint('⚠️ No token found, cannot init socket');
      return;
    }

    // Socket.io should connect to the root domain, not the /api path
    String socketUrl = apiClient.dio.options.baseUrl;
    if (socketUrl.contains('/api')) {
      socketUrl = socketUrl.substring(0, socketUrl.indexOf('/api'));
    }

    debugPrint('🔌 Connecting to Socket: $socketUrl');
    _socket = IO.io(socketUrl, IO.OptionBuilder()
      .setTransports(['websocket'])
      .setAuth({'token': token})
      .enableAutoConnect()
      .build());

    _socket!.onConnect((_) async {
      _isConnected = true;
      debugPrint('✅ Socket connected to $socketUrl: ${_socket!.id}');
      
      // Subscribe to personal notifications
      try {
        final user = await authLocalDataSource.getCachedUser();
        _socket!.emit('subscribe_notification', {'userId': user.userId});
        debugPrint('📡 Subscribed to notification room: user_${user.userId}');
      } catch (e) {
        debugPrint('⚠️ Error getting cached user for socket: $e');
      }
      
      notifyListeners();
    });

    _socket!.onDisconnect((_) {
      _isConnected = false;
      debugPrint('❌ Socket disconnected from $socketUrl');
      notifyListeners();
    });

    _socket!.onConnectError((err) {
      debugPrint('⚠️ Socket connection error for $socketUrl: $err');
    });

    // Listen for personal notifications
    _socket!.on('notification', (data) {
      debugPrint('🔔 REAL-TIME EVENT: New notification received: $data');
      try {
        // Add new notification to the top of the list immediately
        final newNotification = NotificationModel.fromJson(data);
        _notifications.insert(0, newNotification);
        
        // Fetch fresh unread count from server
        fetchUnreadCount();
        
        notifyListeners();
      } catch (e) {
        debugPrint('Error parsing notification socket data: $e');
        fetchNotifications(refresh: true);
      }
    });

    // Listen for Kanban updates
    _socket!.on('kanban_update', (data) {
      debugPrint('📊 KANBAN EVENT: Kanban updated: $data');
      _kanbanUpdateController.add({'type': 'update', ...data});
    });

    // Listen for Kanban note updates
    _socket!.on('kanban_note', (data) {
      debugPrint('📝 KANBAN EVENT: Kanban note updated: $data');
      _kanbanUpdateController.add({'type': 'note', ...data});
    });

    // Listen for new application notes (Application Detail)
    _socket!.on('new_note', (data) {
      debugPrint('📝 DETAIL EVENT: New note received: $data');
      _kanbanUpdateController.add({'type': 'new_note', ...data});
    });
  }

  void subscribeJobKanban(int jobId) {
    _socket?.emit('subscribe_job_kanban', {'jobId': jobId});
  }

  void unsubscribeJobKanban(int jobId) {
    _socket?.emit('unsubscribe_job_kanban', {'jobId': jobId});
  }

  void subscribeApplicationDetail(int applicationId) {
    _socket?.emit('subscribe_application_detail', {'applicationId': applicationId});
  }

  void unsubscribeApplicationDetail(int applicationId) {
    _socket?.emit('unsubscribe_application_detail', {'applicationId': applicationId});
  }

  @override
  void dispose() {
    _socket?.disconnect();
    _socket?.dispose();
    _kanbanUpdateController.close();
    super.dispose();
  }
}
