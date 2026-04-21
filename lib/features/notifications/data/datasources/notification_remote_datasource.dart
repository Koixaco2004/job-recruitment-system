import 'package:dio/dio.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/error/exceptions.dart';
import '../models/notification_model.dart';

abstract class NotificationRemoteDataSource {
  Future<List<NotificationModel>> getNotifications({
    required int page,
    required int limit,
  });

  Future<int> getUnreadCount();

  Future<bool> markAsRead(int id);

  Future<bool> markAllAsRead();
}

class NotificationRemoteDataSourceImpl implements NotificationRemoteDataSource {
  final ApiClient apiClient;

  NotificationRemoteDataSourceImpl(this.apiClient);

  @override
  Future<List<NotificationModel>> getNotifications({
    required int page,
    required int limit,
  }) async {
    try {
      final response = await apiClient.dio.get(
        '/api/notifications',
        queryParameters: {
          'page': page,
          'limit': limit,
        },
      );

      if (response.statusCode == 200) {
        final List data = response.data['data'] ?? [];
        return data.map((json) => NotificationModel.fromJson(json)).toList();
      }
      throw const ServerException('Lấy danh sách thông báo thất bại');
    } on DioException catch (e) {
      throw ServerException(e.response?.data?['message']?.toString() ?? e.toString());
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<int> getUnreadCount() async {
    try {
      final response = await apiClient.dio.get('/api/notifications/unread-count');
      if (response.statusCode == 200) {
        return response.data['count'] as int;
      }
      throw const ServerException('Lấy số lượng thông báo chưa đọc thất bại');
    } on DioException catch (e) {
      throw ServerException(e.response?.data?['message']?.toString() ?? e.toString());
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<bool> markAsRead(int id) async {
    try {
      final response = await apiClient.dio.patch('/api/notifications/$id/read');
      return response.statusCode == 200;
    } on DioException catch (e) {
      throw ServerException(e.response?.data?['message']?.toString() ?? e.toString());
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<bool> markAllAsRead() async {
    try {
      final response = await apiClient.dio.patch('/api/notifications/mark-all-read');
      return response.statusCode == 200;
    } on DioException catch (e) {
      throw ServerException(e.response?.data?['message']?.toString() ?? e.toString());
    } catch (e) {
      throw ServerException(e.toString());
    }
  }
}
