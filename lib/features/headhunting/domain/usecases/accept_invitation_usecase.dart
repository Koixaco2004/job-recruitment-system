import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../repositories/headhunting_repository.dart';

class AcceptInvitationUseCase {
  final HeadhuntingRepository repository;

  AcceptInvitationUseCase(this.repository);

  Future<Either<Failure, bool>> execute(int id) async {
    return await repository.acceptInvitation(id);
  }
}
