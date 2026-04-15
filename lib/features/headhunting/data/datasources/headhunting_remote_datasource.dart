import '../../../../core/network/api_client.dart';
import '../models/headhunting_candidate_model.dart';

abstract class HeadhuntingRemoteDataSource {
  Future<List<HeadhuntingCandidateModel>> getSuggestedCandidates(int jobId);

  Future<Map<String, dynamic>> searchCandidates({
    String? keyword,
    int? provinceId,
    int? yearsOfExperience,
    int? jobCategoryId,
    int? jobTypeId,
    int page = 1,
  });
}

class HeadhuntingRemoteDataSourceImpl implements HeadhuntingRemoteDataSource {
  final ApiClient apiClient;

  HeadhuntingRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<List<HeadhuntingCandidateModel>> getSuggestedCandidates(int jobId) async {
    final response = await apiClient.dio.get('/api/employers/headhunting/jobs/$jobId/suggested-candidates');
    
    if (response.statusCode == 200 || response.statusCode == 201) {
      final List<dynamic> data = response.data;
      return data.map((json) => HeadhuntingCandidateModel.fromJson(json as Map<String, dynamic>)).toList();
    } else {
      throw Exception('Failed to load suggested candidates');
    }
  }

  @override
  Future<Map<String, dynamic>> searchCandidates({
    String? keyword,
    int? provinceId,
    int? yearsOfExperience,
    int? jobCategoryId,
    int? jobTypeId,
    int page = 1,
  }) async {
    final queryParams = {
      if (keyword != null && keyword.isNotEmpty) 'keyword': keyword,
      if (provinceId != null) 'provinceId': provinceId,
      if (yearsOfExperience != null) 'yearsWorkingExperience': yearsOfExperience,
      if (jobCategoryId != null) 'jobCategoryId': jobCategoryId,
      if (jobTypeId != null) 'jobTypeId': jobTypeId,
      'page': page,
      'limit': 10,
    };

    final response = await apiClient.dio.get(
      '/api/employers/headhunting/candidates',
      queryParameters: queryParams,
    );

    final List<dynamic> data = response.data['data'];
    final candidates = data.map((json) => HeadhuntingCandidateModel.fromJson(json as Map<String, dynamic>)).toList();

    return {
      'candidates': candidates,
      'total': response.data['total'],
      'page': response.data['page'],
      'lastPage': response.data['lastPage'],
    };
  }
}
