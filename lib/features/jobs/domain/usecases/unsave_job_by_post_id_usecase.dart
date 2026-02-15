import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../repositories/job_repository.dart';

/// UseCase để bỏ lưu việc làm theo jobPostId
class UnsaveJobByPostIdUseCase {
  final JobRepository repository;

  UnsaveJobByPostIdUseCase(this.repository);

  Future<Either<Failure, void>> call({
    required int candidateId,
    required int jobPostId,
  }) async {
    return await repository.unsaveJobByJobPostId(
      candidateId: candidateId,
      jobPostId: jobPostId,
    );
  }
}
