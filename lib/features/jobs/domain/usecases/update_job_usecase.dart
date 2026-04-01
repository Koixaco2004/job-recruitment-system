import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/job_post_entity.dart';
import '../repositories/job_repository.dart';

class UpdateJobUseCase {
  final JobRepository repository;

  UpdateJobUseCase(this.repository);

  Future<Either<Failure, JobPostEntity>> call(int jobId, Map<String, dynamic> data) async {
    return await repository.updateJob(jobId, data);
  }
}
