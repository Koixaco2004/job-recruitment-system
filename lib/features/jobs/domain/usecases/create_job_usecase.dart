import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/job_post_entity.dart';
import '../repositories/job_repository.dart';

class CreateJobUseCase {
  final JobRepository repository;

  CreateJobUseCase(this.repository);

  Future<Either<Failure, JobPostEntity>> call(Map<String, dynamic> data) async {
    return await repository.createJob(data);
  }
}
