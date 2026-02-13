import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/application_entity.dart';
import '../repositories/job_repository.dart';

/// Use case để gửi đơn ứng tuyển
class SubmitApplicationUseCase {
  final JobRepository repository;

  SubmitApplicationUseCase(this.repository);

  /// Execute - gửi đơn ứng tuyển
  Future<Either<Failure, ApplicationEntity>> call({
    required int jobPostId,
    required int candidateId,
    String? cvFileUrl,
    String? coverLetter,
  }) async {
    return await repository.submitApplication(
      jobPostId: jobPostId,
      candidateId: candidateId,
      cvFileUrl: cvFileUrl,
      coverLetter: coverLetter,
    );
  }
}
