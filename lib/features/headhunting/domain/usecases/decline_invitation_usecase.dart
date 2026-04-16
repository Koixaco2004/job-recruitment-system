import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../repositories/headhunting_repository.dart';

class DeclineInvitationUseCase {
  final HeadhuntingRepository repository;

  DeclineInvitationUseCase(this.repository);

  Future<Either<Failure, bool>> execute(int id) async {
    return await repository.declineInvitation(id);
  }
}
