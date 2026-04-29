import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../repositories/job_repository.dart';

class BumpJobUseCase {
  final JobRepository repository;

  BumpJobUseCase(this.repository);

  Future<Either<Failure, Map<String, dynamic>>> call(int jobId) async {
    return await repository.bumpJob(jobId);
  }
}
