import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/application_entity.dart';
import '../entities/job_post_entity.dart';
import '../entities/saved_job_entity.dart';
import '../entities/job_status_history_entity.dart';
import '../../../../core/models/paginated_response.dart';

/// Abstract repository cho Jobs
abstract class JobRepository {
  /// Lấy danh sách jobs (Công khai cho ứng viên)
  Future<Either<Failure, PaginatedResponse<JobPostEntity>>> getJobs({
    int page = 1,
    int limit = 10,
    String? keyword,
    int? provinceId,
    int? categoryId,
    int? jobTypeId,
    int? levelId,
  });

  /// Lấy job post theo ID
  Future<Either<Failure, JobPostEntity>> getJobById(int jobId);

  /// Tìm kiếm jobs theo keyword (Có thể dùng getJobs thay thế)
  Future<Either<Failure, List<JobPostEntity>>> searchJobs(String keyword);

  /// Gửi đơn ứng tuyển
  Future<Either<Failure, ApplicationEntity>> submitApplication({
    required int jobPostId,
    required int candidateId,
    String? cvFileUrl,
    String? coverLetter,
  });

  /// Lấy danh sách việc đã lưu
  Future<Either<Failure, List<SavedJobEntity>>> getSavedJobs(int candidateId);

  /// Lưu việc làm
  Future<Either<Failure, SavedJobEntity>> saveJob({
    required int candidateId,
    required int jobPostId,
  });

  /// Bỏ lưu việc làm
  Future<Either<Failure, void>> unsaveJob(int savedJobId);

  /// Bỏ lưu việc làm theo jobPostId
  Future<Either<Failure, void>> unsaveJobByJobPostId({
    required int candidateId,
    required int jobPostId,
  });

  /// Lấy danh sách đơn ứng tuyển của candidate
  Future<Either<Failure, List<ApplicationEntity>>> getMyApplications(
    int candidateId,
  );

  /// Kiểm tra job đã được lưu chưa
  Future<Either<Failure, bool>> isJobSaved({
    required int candidateId,
    required int jobPostId,
  });

  // --- Employer - Job Management ---

  /// Tạo mới tin tuyển dụng (Draft)
  Future<Either<Failure, JobPostEntity>> createJob(Map<String, dynamic> data);

  /// Cập nhật tin tuyển dụng (bao gồm Publish)
  Future<Either<Failure, JobPostEntity>> updateJob(int jobId, Map<String, dynamic> data);

  /// Lấy danh sách tin tuyển dụng của HR
  Future<Either<Failure, PaginatedResponse<JobPostEntity>>> getMyJobsForEmployer({
    int page = 1,
    int limit = 10,
    String? status,
  });

  /// Lấy lịch sử thay đổi trạng thái của tin tuyển dụng
  Future<Either<Failure, List<JobStatusHistoryEntity>>> getJobHistory(int jobId);
}
