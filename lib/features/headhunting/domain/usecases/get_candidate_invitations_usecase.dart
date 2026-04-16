import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/candidate_invitation_entity.dart';
import '../repositories/headhunting_repository.dart';

class GetCandidateInvitationsUseCase {
  final HeadhuntingRepository repository;

  GetCandidateInvitationsUseCase(this.repository);

  Future<Either<Failure, List<CandidateInvitationEntity>>> execute() async {
    return await repository.getCandidateInvitations();
  }
}
