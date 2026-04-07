import 'package:dio/dio.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/models/paginated_response.dart';
import '../models/application_model.dart';
import '../models/application_kanban_column_model.dart';
import '../models/application_status_history_model.dart';

abstract class EmployerApplicationRemoteDataSource {
  Future<PaginatedResponse<ApplicationModel>> getJobApplications(
    int jobId, {
    int page = 1,
    int limit = 10,
    String? status,
  });

  Future<List<ApplicationKanbanColumnModel>> getKanbanBoard(int jobId);

  Future<ApplicationModel> getEmployerApplicationDetail(int id);

  Future<List<ApplicationStatusHistoryModel>> getApplicationHistory(int id);

  Future<void> updateApplicationStatus(
    int id,
    String status, {
    String? reason,
    String? note,
  });
}

class EmployerApplicationRemoteDataSourceImpl
    implements EmployerApplicationRemoteDataSource {
  final ApiClient apiClient;

  EmployerApplicationRemoteDataSourceImpl(this.apiClient);

  @override
  Future<PaginatedResponse<ApplicationModel>> getJobApplications(
    int jobId, {
    int page = 1,
    int limit = 10,
    String? status,
  }) async {
    try {
      final queryParams = {
        'page': page,
        'limit': limit,
        if (status != null) 'status': status,
      };

      final response = await apiClient.dio.get(
        '/api/employer/applications/job/$jobId',
        queryParameters: queryParams,
      );

      if (response.statusCode == 200) {
        return PaginatedResponse.fromJson(
          response.data,
          (json) => ApplicationModel.fromJson(json as Map<String, dynamic>),
        );
      }
      throw const ServerException('Lấy danh sách ứng viên thất bại');
    } on DioException catch (e) {
      throw ServerException(e.response?.data?['message']?.toString() ?? e.toString());
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<List<ApplicationKanbanColumnModel>> getKanbanBoard(int jobId) async {
    try {
      final response = await apiClient.dio.get(
        '/api/employer/applications/job/$jobId/kanban',
      );

      if (response.statusCode == 200) {
        final dynamic rawData = response.data;
        List data;
        
        if (rawData is Map && rawData.containsKey('data')) {
          data = rawData['data'];
        } else if (rawData is List) {
          data = rawData;
        } else {
          data = [];
        }

        return data
            .map((e) => ApplicationKanbanColumnModel.fromJson(e as Map<String, dynamic>))
            .toList();
      }
      throw const ServerException('Lấy Kanban board thất bại');
    } on DioException catch (e) {
      throw ServerException(e.response?.data?['message']?.toString() ?? e.toString());
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<ApplicationModel> getEmployerApplicationDetail(int id) async {
    try {
      final response = await apiClient.dio.get(
        '/api/employer/applications/$id',
      );

      if (response.statusCode == 200) {
        return ApplicationModel.fromJson(response.data as Map<String, dynamic>);
      }
      throw const ServerException('Lấy chi tiết hồ sơ thất bại');
    } on DioException catch (e) {
      throw ServerException(e.response?.data?['message']?.toString() ?? e.toString());
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<List<ApplicationStatusHistoryModel>> getApplicationHistory(int id) async {
    try {
      final response = await apiClient.dio.get(
        '/api/employer/applications/$id/history',
      );

      if (response.statusCode == 200) {
        final rawData = response.data;
        List data;
        if (rawData is List) {
          data = rawData;
        } else if (rawData is Map && rawData.containsKey('data')) {
          data = rawData['data'];
        } else {
          data = [];
        }

        return data
            .map((e) => ApplicationStatusHistoryModel.fromJson(e as Map<String, dynamic>))
            .toList();
      }
      throw const ServerException('Lấy lịch sử ứng tuyển thất bại');
    } on DioException catch (e) {
      throw ServerException(e.response?.data?['message']?.toString() ?? e.toString());
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<void> updateApplicationStatus(
    int id,
    String status, {
    String? reason,
    String? note,
  }) async {
    try {
      final response = await apiClient.dio.patch(
        '/api/employer/applications/$id/status',
        data: {
          'status': status,
          if (reason != null) 'reason': reason,
          if (note != null) 'note': note,
        },
      );

      if (response.statusCode != 200 && response.statusCode != 204) {
        throw const ServerException('Cập nhật trạng thái thất bại');
      }
    } on DioException catch (e) {
      throw ServerException(e.response?.data?['message']?.toString() ?? e.toString());
    } catch (e) {
      throw ServerException(e.toString());
    }
  }
}
