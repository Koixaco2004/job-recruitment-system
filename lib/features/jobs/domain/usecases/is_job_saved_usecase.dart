import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../repositories/job_repository.dart';

/// UseCase để kiểm tra xem một tin tuyển dụng đã được ứng viên lưu chưa
class IsJobSavedUseCase {
  final JobRepository repository;

  IsJobSavedUseCase(this.repository);

  Future<Either<Failure, bool>> call({
    required int candidateId,
    required int jobPostId,
  }) async {
    return await repository.isJobSaved(
      candidateId: candidateId,
      jobPostId: jobPostId,
    );
  }
}
