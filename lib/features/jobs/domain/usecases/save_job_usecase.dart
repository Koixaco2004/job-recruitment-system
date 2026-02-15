import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/saved_job_entity.dart';
import '../repositories/job_repository.dart';

/// UseCase để lưu việc làm
class SaveJobUseCase {
  final JobRepository repository;

  SaveJobUseCase(this.repository);

  Future<Either<Failure, SavedJobEntity>> call({
    required int candidateId,
    required int jobPostId,
  }) async {
    return await repository.saveJob(
      candidateId: candidateId,
      jobPostId: jobPostId,
    );
  }
}
