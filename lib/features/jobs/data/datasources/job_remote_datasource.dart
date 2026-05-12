import 'package:dio/dio.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/error/exceptions.dart';
import '../models/application_model.dart';
import '../models/job_post_model.dart';
import '../models/saved_job_model.dart';
import '../models/job_status_history_model.dart';
import '../../../../core/models/paginated_response.dart';

/// Abstract interface cho Remote Data Source
abstract class JobRemoteDataSource {
  /// Lấy danh sách jobs từ API (Công khai cho ứng viên)
  Future<PaginatedResponse<JobPostModel>> getJobs({
    int page = 1,
    int limit = 10,
    String? keyword,
    int? provinceId,
    int? categoryId,
    int? jobTypeId,
    int? levelId,
    int? salaryMin,
    int? salaryMax,
    String? requiredDegree,
    int? maxYearsRequired,
    List<int>? skillIds,
    String? sortBy,
    String? sortOrder,
  });

  /// Lấy job theo ID
  Future<JobPostModel> getJobById(int jobId);

  /// Gửi đơn ứng tuyển
  Future<ApplicationModel> submitApplication({
    required int jobPostId,
    required int candidateId,
    String? cvFileUrl,
    String? coverLetter,
  });

  /// Lấy danh sách việc đã lưu
  Future<List<SavedJobModel>> getSavedJobs(int candidateId);

  /// Lưu việc làm
  Future<SavedJobModel> saveJob({
    required int candidateId,
    required int jobPostId,
  });

  /// Bỏ lưu việc làm
  Future<void> unsaveJob(int savedJobId);

  /// Bỏ lưu việc làm theo jobPostId
  Future<void> unsaveJobByJobPostId({
    required int candidateId,
    required int jobPostId,
  });

  /// Lấy danh sách đơn ứng tuyển
  Future<List<ApplicationModel>> getMyApplications(int candidateId);

  /// Kiểm tra job đã được lưu chưa
  Future<bool> isJobSaved({required int candidateId, required int jobPostId});

  // --- Employer - Job Management ---
  
  /// Tạo mới tin tuyển dụng (Draft)
  Future<JobPostModel> createJob(Map<String, dynamic> data);

  /// Cập nhật tin tuyển dụng (bao gồm Publish)
  Future<JobPostModel> updateJob(int jobId, Map<String, dynamic> data);

  /// Lấy danh sách tin tuyển dụng của trang chủ HR
  Future<PaginatedResponse<JobPostModel>> getMyJobsForEmployer({
    int page = 1,
    int limit = 10,
    String? status,
  });

  /// Lấy lịch sử thay đổi trạng thái của tin tuyển dụng
  Future<List<JobStatusHistoryModel>> getJobHistory(int jobId);

  /// Đẩy tin tuyển dụng (Bump)
  Future<Map<String, dynamic>> bumpJob(int jobId);
}

/// Implementation với API thật (và một số mock cho candidate)
class JobRemoteDataSourceImpl implements JobRemoteDataSource {
  final ApiClient apiClient;

  JobRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<PaginatedResponse<JobPostModel>> getJobs({
    int page = 1,
    int limit = 10,
    String? keyword,
    int? provinceId,
    int? categoryId,
    int? jobTypeId,
    int? levelId,
    int? salaryMin,
    int? salaryMax,
    String? requiredDegree,
    int? maxYearsRequired,
    List<int>? skillIds,
    String? sortBy,
    String? sortOrder,
  }) async {
    try {
      final queryParams = {
        'page': page,
        'limit': limit,
        if (keyword != null && keyword.isNotEmpty) 'keyword': keyword,
        if (provinceId != null) 'provinceId': provinceId,
        if (categoryId != null) 'categoryId': categoryId,
        if (jobTypeId != null) 'jobTypeId': jobTypeId,
        if (levelId != null) 'levelId': levelId,
        if (salaryMin != null) 'salaryMin': salaryMin,
        if (salaryMax != null) 'salaryMax': salaryMax,
        if (requiredDegree != null) 'requiredDegree': requiredDegree,
        if (maxYearsRequired != null) 'maxYearsRequired': maxYearsRequired,
        if (skillIds != null && skillIds!.isNotEmpty) 'skillIds': skillIds,
        if (sortBy != null) 'sortBy': sortBy,
        if (sortOrder != null) 'sortOrder': sortOrder,
      };

      final response = await apiClient.dio.get('/api/jobs/public', queryParameters: queryParams);
      
      if (response.statusCode == 200) {
        return PaginatedResponse.fromJson(
          response.data,
          (json) => JobPostModel.fromJson(json as Map<String, dynamic>),
        );
      }
      throw const ServerException('Lấy danh sách công việc thất bại');
    } on DioException catch (e) {
      if (e.error is EmailVerificationException) rethrow;
      throw ServerException(e.response?.data?['message']?.toString() ?? e.toString());
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<JobPostModel> getJobById(int jobId) async {
    try {
      final response = await apiClient.dio.get('/api/jobs/public/$jobId');
      
      if (response.statusCode == 200) {
        final data = response.data['data'] ?? response.data;
        return JobPostModel.fromJson(data);
      }
      throw const ServerException('Không tìm thấy thông tin công việc');
    } on DioException catch (e) {
      if (e.error is EmailVerificationException) rethrow;
      throw ServerException(e.response?.data?['message']?.toString() ?? e.toString());
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  // === Mock storage cho saved jobs và applications (Candidate) ===
  final List<SavedJobModel> _mockSavedJobs = [];
  final List<ApplicationModel> _mockApplications = [];

  @override
  Future<ApplicationModel> submitApplication({
    required int jobPostId,
    required int candidateId,
    String? cvFileUrl,
    String? coverLetter,
  }) async {
    await Future.delayed(const Duration(seconds: 1));
    
    // Mocking submission result as API might not be available or needs specific auth
    return ApplicationModel(
      applicationId: DateTime.now().millisecondsSinceEpoch,
      jobPostId: jobPostId,
      candidateId: candidateId,
      cvFileUrl: cvFileUrl,
      coverLetter: coverLetter,
      status: 'submitted',
      appliedAt: DateTime.now(),
    );
  }

  @override
  Future<List<SavedJobModel>> getSavedJobs(int candidateId) async {
    try {
      final response = await apiClient.dio.get('/api/candidates/saved-jobs');
      
      if (response.statusCode == 200) {
        final List data = response.data['data'] ?? [];
        return data.map((e) => SavedJobModel.fromJson(e)).toList();
      }
      throw const ServerException('Lấy danh sách việc làm đã lưu thất bại');
    } on DioException catch (e) {
      throw ServerException(e.response?.data?['message']?.toString() ?? e.toString());
    }
  }

  @override
  Future<SavedJobModel> saveJob({
    required int candidateId,
    required int jobPostId,
  }) async {
    try {
      final response = await apiClient.dio.post('/api/candidates/saved-jobs/$jobPostId');
      
      if (response.statusCode == 201 || response.statusCode == 200) {
        // API response for save might be simple message, so we create a model locally or return what's returned
        // Based on user res: {"message": "Đã lưu việc làm thành công", "saved": true}
        return SavedJobModel(
          savedJobId: 0, // Not provided by message response
          candidateId: candidateId,
          jobPostId: jobPostId,
          createdAt: DateTime.now(),
        );
      }
      throw const ServerException('Lưu việc làm thất bại');
    } on DioException catch (e) {
      throw ServerException(e.response?.data?['message']?.toString() ?? e.toString());
    }
  }

  @override
  Future<void> unsaveJob(int savedJobId) async {
    // Legacy support - might not work if savedJobId is not jobId
    // Recommended to use unsaveJobByJobPostId
    throw const ServerException('Vui lòng sử dụng unsaveJobByJobPostId');
  }

  @override
  Future<void> unsaveJobByJobPostId({
    required int candidateId,
    required int jobPostId,
  }) async {
    try {
      final response = await apiClient.dio.delete('/api/candidates/saved-jobs/$jobPostId');
      
      if (response.statusCode != 200 && response.statusCode != 204) {
        throw const ServerException('Bỏ lưu việc làm thất bại');
      }
    } on DioException catch (e) {
      throw ServerException(e.response?.data?['message']?.toString() ?? e.toString());
    }
  }

  @override
  Future<List<ApplicationModel>> getMyApplications(int candidateId) async {
    // Applications might still be mock or implemented separately
    await Future.delayed(const Duration(milliseconds: 500));
    return _mockApplications.where((a) => a.candidateId == candidateId).toList();
  }

  @override
  Future<bool> isJobSaved({required int candidateId, required int jobPostId}) async {
    try {
      final response = await apiClient.dio.get('/api/candidates/saved-jobs/$jobPostId/check');
      
      if (response.statusCode == 200) {
        return response.data['isSaved'] == true;
      }
      return false;
    } on DioException catch (e) {
      // If 404, assume not saved
      if (e.response?.statusCode == 404) return false;
      throw ServerException(e.response?.data?['message']?.toString() ?? e.toString());
    }
  }

  // --- Employer API Implementation ---

  @override
  Future<JobPostModel> createJob(Map<String, dynamic> data) async {
    try {
      final response = await apiClient.dio.post('/api/jobs/employer', data: data);
      if (response.statusCode == 201 || response.statusCode == 200) {
        final jobData = response.data['data'] ?? response.data;
        return JobPostModel.fromJson(jobData);
      }
      throw const ServerException('Tạo tin tuyển dụng thất bại');
    } on DioException catch (e) {
      if (e.error is EmailVerificationException) rethrow;
      throw ServerException(e.response?.data?['message']?.toString() ?? e.toString());
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<JobPostModel> updateJob(int jobId, Map<String, dynamic> data) async {
    try {
      final response = await apiClient.dio.put('/api/jobs/employer/$jobId', data: data);
      if (response.statusCode == 200) {
        final jobData = response.data['data'] ?? response.data;
        return JobPostModel.fromJson(jobData);
      }
      throw const ServerException('Cập nhật tin tuyển dụng thất bại');
    } on DioException catch (e) {
      if (e.error is EmailVerificationException) rethrow;
      throw ServerException(e.response?.data?['message']?.toString() ?? e.toString());
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<PaginatedResponse<JobPostModel>> getMyJobsForEmployer({
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
      
      final response = await apiClient.dio.get('/api/jobs/employer', queryParameters: queryParams);
      
      if (response.statusCode == 200) {
        return PaginatedResponse.fromJson(
          response.data,
          (json) => JobPostModel.fromJson(json as Map<String, dynamic>),
        );
      }
      throw const ServerException('Lấy danh sách tin tuyển dụng thất bại');
    } on DioException catch (e) {
      if (e.error is EmailVerificationException) rethrow;
      throw ServerException(e.response?.data?['message']?.toString() ?? e.toString());
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<List<JobStatusHistoryModel>> getJobHistory(int jobId) async {
    try {
      final response = await apiClient.dio.get('/api/jobs/employer/$jobId/history');
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
        
        return data.map((e) => JobStatusHistoryModel.fromJson(e)).toList();
      }
      throw const ServerException('Lấy lịch sử tin tuyển dụng thất bại');
    } on DioException catch (e) {
      if (e.error is EmailVerificationException) rethrow;
      throw ServerException(e.response?.data?['message']?.toString() ?? e.toString());
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<Map<String, dynamic>> bumpJob(int jobId) async {
    try {
      final response = await apiClient.dio.post('/api/jobs/employer/$jobId/bump');
      if (response.statusCode == 200 || response.statusCode == 201) {
        return response.data as Map<String, dynamic>;
      }
      throw const ServerException('Đẩy tin thất bại');
    } on DioException catch (e) {
      if (e.error is EmailVerificationException) rethrow;
      throw ServerException(e.response?.data?['message']?.toString() ?? e.toString());
    } catch (e) {
      throw ServerException(e.toString());
    }
  }
}
