import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/job_post_entity.dart';
import '../repositories/job_repository.dart';

/// Use case để lấy danh sách jobs
class GetJobsUseCase {
  final JobRepository repository;

  GetJobsUseCase(this.repository);

  /// Execute - lấy tất cả jobs
  Future<Either<Failure, List<JobPostEntity>>> call() async {
    return await repository.getJobs();
  }
}
