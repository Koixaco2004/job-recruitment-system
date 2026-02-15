import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/application_entity.dart';
import '../entities/job_post_entity.dart';
import '../entities/saved_job_entity.dart';

/// Abstract repository cho Jobs
abstract class JobRepository {
  /// Lấy danh sách tất cả job posts
  Future<Either<Failure, List<JobPostEntity>>> getJobs();

  /// Lấy job post theo ID
  Future<Either<Failure, JobPostEntity>> getJobById(int jobId);

  /// Tìm kiếm jobs theo keyword
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
}
