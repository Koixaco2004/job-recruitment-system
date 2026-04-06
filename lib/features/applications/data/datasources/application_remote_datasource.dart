import '../../../../core/network/api_client.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/models/paginated_response.dart';
import '../models/application_model.dart';

abstract class ApplicationRemoteDataSource {
  Future<ApplicationModel> apply({
    required int jobId,
    String? coverLetter,
  });

  Future<PaginatedResponse<ApplicationModel>> getMyApplications({
    int page = 1,
    int limit = 10,
    String? status,
  });

  Future<ApplicationModel> getApplicationDetail(int id);

  Future<void> withdrawApplication(int id);
}

class ApplicationRemoteDataSourceImpl implements ApplicationRemoteDataSource {
  final ApiClient apiClient;

  ApplicationRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<ApplicationModel> apply({
    required int jobId,
    String? coverLetter,
  }) async {
    try {
      final response = await apiClient.dio.post(
        '/api/applications/$jobId',
        data: {
          if (coverLetter != null) 'coverLetter': coverLetter,
        },
      );
      return ApplicationModel.fromJson(response.data);
    } catch (e) {
      throw ServerException(e.toString());
    }

  }

  @override
  Future<PaginatedResponse<ApplicationModel>> getMyApplications({
    int page = 1,
    int limit = 10,
    String? status,
  }) async {
    try {
      final response = await apiClient.dio.get(
        '/api/applications/me',
        queryParameters: {
          'page': page,
          'limit': limit,
          if (status != null) 'status': status,
        },
      );
      
      return PaginatedResponse.fromJson(
        response.data,
        (json) => ApplicationModel.fromJson(json as Map<String, dynamic>),
      );
    } catch (e) {
      throw ServerException(e.toString());
    }

  }

  @override
  Future<ApplicationModel> getApplicationDetail(int id) async {
    try {
      final response = await apiClient.dio.get('/api/applications/me/$id');
      return ApplicationModel.fromJson(response.data);
    } catch (e) {
      throw ServerException(e.toString());
    }

  }

  @override
  Future<void> withdrawApplication(int id) async {
    try {
      await apiClient.dio.patch('/api/applications/me/$id/withdraw');
    } catch (e) {
      throw ServerException(e.toString());
    }

  }
}
