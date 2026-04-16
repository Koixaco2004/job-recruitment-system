import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/employer_invitation_entity.dart';
import '../repositories/headhunting_repository.dart';

class GetEmployerInvitationsUseCase {
  final HeadhuntingRepository repository;

  GetEmployerInvitationsUseCase(this.repository);

  Future<Either<Failure, List<EmployerInvitationEntity>>> execute() async {
    return await repository.getEmployerInvitations();
  }
}
