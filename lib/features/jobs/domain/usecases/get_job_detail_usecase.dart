import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/job_post_entity.dart';
import '../repositories/job_repository.dart';

/// Use case để lấy chi tiết một job
class GetJobDetailUseCase {
  final JobRepository repository;

  GetJobDetailUseCase(this.repository);

  /// Execute - lấy job theo ID
  Future<Either<Failure, JobPostEntity>> call(int jobId) async {
    return await repository.getJobById(jobId);
  }
}
