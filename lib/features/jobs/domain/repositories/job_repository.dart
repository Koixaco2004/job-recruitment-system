import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/application_entity.dart';
import '../entities/job_post_entity.dart';

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
}
