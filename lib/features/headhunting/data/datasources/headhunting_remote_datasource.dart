import '../../../../core/network/api_client.dart';
import '../models/headhunting_candidate_model.dart';

abstract class HeadhuntingRemoteDataSource {
  Future<List<HeadhuntingCandidateModel>> getSuggestedCandidates(int jobId);
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
}
