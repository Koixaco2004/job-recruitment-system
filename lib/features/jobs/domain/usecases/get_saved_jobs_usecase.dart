import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/saved_job_entity.dart';
import '../repositories/job_repository.dart';

/// UseCase để lấy danh sách việc đã lưu
class GetSavedJobsUseCase {
  final JobRepository repository;

  GetSavedJobsUseCase(this.repository);

  Future<Either<Failure, List<SavedJobEntity>>> call(int candidateId) async {
    return await repository.getSavedJobs(candidateId);
  }
}
