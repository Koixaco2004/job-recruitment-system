import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../repositories/headhunting_repository.dart';

class SendInvitationParams {
  final int jobId;
  final int candidateId;
  final String message;

  SendInvitationParams({
    required this.jobId,
    required this.candidateId,
    required this.message,
  });
}

class SendInvitationUseCase {
  final HeadhuntingRepository repository;

  SendInvitationUseCase(this.repository);

  Future<Either<Failure, bool>> call(SendInvitationParams params) async {
    return await repository.sendInvitation(
      jobId: params.jobId,
      candidateId: params.candidateId,
      message: params.message,
    );
  }
}
