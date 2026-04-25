import 'package:dio/dio.dart';
import '../../../../core/network/api_client.dart';
import '../models/headhunting_candidate_model.dart';
import '../models/candidate_detail_model.dart';
import '../models/candidate_invitation_model.dart';
import '../models/employer_invitation_model.dart';
import '../models/saved_candidate_model.dart';

abstract class HeadhuntingRemoteDataSource {
  Future<List<HeadhuntingCandidateModel>> getSuggestedCandidates(int jobId);

  Future<Map<String, dynamic>> searchCandidates({
    String? keyword,
    int? provinceId,
    int? minExperience,
    List<int>? categoryIds,
    List<int>? skillIds,
    int? jobTypeId,
    int? salaryMin,
    int? salaryMax,
    String? sortBy,
    String? sortOrder,
    int page = 1,
  });

  Future<CandidateDetailModel> getCandidateDetail(int id);

  Future<bool> sendInvitation({
    required int jobId,
    required int candidateId,
    required String message,
  });

  // Candidate Side
  Future<List<CandidateInvitationModel>> getCandidateInvitations();
  Future<bool> acceptInvitation(int id);
  Future<bool> declineInvitation(int id);

  // Employer Side
  Future<List<EmployerInvitationModel>> getEmployerInvitations();
  Future<bool> saveCandidate(int candidateId, {String? note});
  Future<bool> unsaveCandidate(int candidateId);
  Future<List<SavedCandidateModel>> getSavedCandidates();
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
    int? minExperience,
    List<int>? categoryIds,
    List<int>? skillIds,
    int? jobTypeId,
    int? salaryMin,
    int? salaryMax,
    String? sortBy,
    String? sortOrder,
    int page = 1,
  }) async {
    final queryParams = {
      if (keyword != null && keyword.isNotEmpty) 'keyword': keyword,
      if (provinceId != null) 'provinceId': provinceId,
      if (minExperience != null) 'minExperience': minExperience,
      if (categoryIds != null && categoryIds.isNotEmpty) 'categoryIds': categoryIds,
      if (skillIds != null && skillIds.isNotEmpty) 'skillIds': skillIds,
      if (jobTypeId != null) 'jobTypeId': jobTypeId,
      if (salaryMin != null) 'salaryMin': salaryMin,
      if (salaryMax != null) 'salaryMax': salaryMax,
      if (sortBy != null) 'sortBy': sortBy,
      if (sortOrder != null) 'sortOrder': sortOrder,
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

  @override
  Future<CandidateDetailModel> getCandidateDetail(int id) async {
    final response = await apiClient.dio.get('/api/employers/headhunting/candidates/$id');
    
    if (response.statusCode == 200 || response.statusCode == 201) {
      return CandidateDetailModel.fromJson(response.data as Map<String, dynamic>);
    } else {
      throw Exception('Failed to load candidate detail');
    }
  }

  @override
  Future<bool> sendInvitation({
    required int jobId,
    required int candidateId,
    required String message,
  }) async {
    try {
      final response = await apiClient.dio.post(
        '/api/employers/headhunting/invitations',
        data: {
          'jobId': jobId,
          'candidateId': candidateId,
          'message': message,
        },
      );

      return response.statusCode == 200 || response.statusCode == 201;
    } on DioException catch (e) {
      if (e.response != null && e.response!.data is Map) {
        final errorMessage = e.response!.data['message'];
        if (errorMessage != null) {
          throw Exception(errorMessage);
        }
      }
      rethrow;
    }
  }

  @override
  Future<List<CandidateInvitationModel>> getCandidateInvitations() async {
    final response = await apiClient.dio.get('/api/candidates/headhunting/invitations');
    
    if (response.statusCode == 200 || response.statusCode == 201) {
      final List<dynamic> data = response.data;
      return data.map((json) => CandidateInvitationModel.fromJson(json as Map<String, dynamic>)).toList();
    } else {
      throw Exception('Failed to load candidate invitations');
    }
  }

  @override
  Future<bool> acceptInvitation(int id) async {
    final response = await apiClient.dio.post('/api/candidates/headhunting/invitations/$id/accept');
    return response.statusCode == 200 || response.statusCode == 201;
  }

  @override
  Future<bool> declineInvitation(int id) async {
    final response = await apiClient.dio.post('/api/candidates/headhunting/invitations/$id/decline');
    return response.statusCode == 200 || response.statusCode == 201;
  }

  @override
  Future<List<EmployerInvitationModel>> getEmployerInvitations() async {
    final response = await apiClient.dio.get('/api/employers/headhunting/invitations');
    
    if (response.statusCode == 200 || response.statusCode == 201) {
      final List<dynamic> data = response.data;
      return data.map((json) => EmployerInvitationModel.fromJson(json as Map<String, dynamic>)).toList();
    } else {
      throw Exception('Failed to load employer invitations');
    }
  }

  @override
  Future<bool> saveCandidate(int candidateId, {String? note}) async {
    final response = await apiClient.dio.post(
      '/api/employers/headhunting/saved-candidates/$candidateId',
      data: note != null ? {'note': note} : null,
    );
    return response.statusCode == 200 || response.statusCode == 201;
  }

  @override
  Future<bool> unsaveCandidate(int candidateId) async {
    final response = await apiClient.dio.delete('/api/employers/headhunting/saved-candidates/$candidateId');
    return response.statusCode == 200 || response.statusCode == 201;
  }

  @override
  Future<List<SavedCandidateModel>> getSavedCandidates() async {
    final response = await apiClient.dio.get('/api/employers/headhunting/saved-candidates');
    
    if (response.statusCode == 200 || response.statusCode == 201) {
      final List<dynamic> data = response.data;
      return data.map((json) => SavedCandidateModel.fromJson(json as Map<String, dynamic>)).toList();
    } else {
      throw Exception('Failed to load saved candidates');
    }
  }
}
