import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/notification_provider.dart';
import '../../domain/entities/notification_entity.dart';
import '../../../applications/presentation/pages/application_detail_page.dart';
import '../../../headhunting/presentation/pages/candidate_invitation_list_page.dart';

class NotificationListPage extends StatefulWidget {
  const NotificationListPage({super.key});

  @override
  State<NotificationListPage> createState() => _NotificationListPageState();
}

class _NotificationListPageState extends State<NotificationListPage> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<NotificationProvider>().fetchNotifications(refresh: true);
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      context.read<NotificationProvider>().fetchNotifications();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Thông báo', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          TextButton(
            onPressed: () {
              context.read<NotificationProvider>().markAllNotificationsAsRead();
            },
            child: const Text('Đọc tất cả'),
          ),
        ],
      ),
      body: Consumer<NotificationProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading && provider.notifications.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.errorMessage != null && provider.notifications.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(provider.errorMessage!),
                  ElevatedButton(
                    onPressed: () => provider.fetchNotifications(refresh: true),
                    child: const Text('Thử lại'),
                  ),
                ],
              ),
            );
          }

          if (provider.notifications.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.notifications_off_outlined, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  const Text('Không có thông báo nào', style: TextStyle(color: Colors.grey)),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () => provider.fetchNotifications(refresh: true),
            child: ListView.separated(
              controller: _scrollController,
              itemCount: provider.notifications.length + (provider.isLoading ? 1 : 0),
              separatorBuilder: (context, index) => const Divider(height: 1),
              itemBuilder: (context, index) {
                if (index == provider.notifications.length) {
                  return const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }

                final notification = provider.notifications[index];
                return _NotificationItem(notification: notification);
              },
            ),
          );
        },
      ),
    );
  }
}

class _NotificationItem extends StatelessWidget {
  final NotificationEntity notification;

  const _NotificationItem({required this.notification});

  IconData _getIcon() {
    switch (notification.type) {
      case 'application_status':
        return Icons.assignment_turned_in_outlined;
      case 'headhunt_invitation':
        return Icons.mail_outline;
      case 'headhunt_accept':
        return Icons.check_circle_outline;
      case 'headhunt_reject':
        return Icons.cancel_outlined;
      case 'job_approval':
        return Icons.published_with_changes;
      case 'system':
        return Icons.info_outline;
      default:
        return Icons.notifications_none_outlined;
    }
  }

  Color _getIconColor() {
    switch (notification.type) {
      case 'application_status':
        return Colors.blue;
      case 'headhunt_invitation':
        return Colors.orange;
      case 'headhunt_accept':
        return Colors.green;
      case 'headhunt_reject':
        return Colors.red;
      case 'job_approval':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        context.read<NotificationProvider>().markNotificationAsRead(notification.id);
        
        final metadata = notification.metadata;
        
        // Navigation logic based on type and metadata
        if (notification.type == 'application_status' || notification.type == 'application_update') {
          final appId = metadata['applicationId'];
          if (appId != null) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ApplicationDetailPage(applicationId: int.parse(appId.toString())),
              ),
            );
          }
        } else if (notification.type == 'headhunt_invitation') {
          // Navigate to invitations list
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const CandidateInvitationListPage(),
            ),
          );
        } else if (notification.type == 'job_approval' || notification.type == 'job_rejected') {
          // For Employer - potentially navigate to job list or edit page
          // jobId is usually in metadata
        }
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        color: notification.isRead ? Colors.transparent : Colors.blue.withOpacity(0.05),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              backgroundColor: _getIconColor().withOpacity(0.1),
              child: Icon(_getIcon(), color: _getIconColor(), size: 20),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          notification.title,
                          style: TextStyle(
                            fontWeight: notification.isRead ? FontWeight.normal : FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                      ),
                      if (!notification.isRead)
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(color: Colors.blue, shape: BoxShape.circle),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    notification.content,
                    style: TextStyle(color: Colors.grey[700], fontSize: 13),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    DateFormat('HH:mm, dd/MM/yyyy').format(notification.createdAt),
                    style: TextStyle(color: Colors.grey[500], fontSize: 11),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
