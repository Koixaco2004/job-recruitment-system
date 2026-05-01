import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/candidate_detail_entity.dart';
import '../repositories/headhunting_repository.dart';

class UnlockCandidateContactUseCase {
  final HeadhuntingRepository repository;

  UnlockCandidateContactUseCase(this.repository);

  Future<Either<Failure, CandidateDetailEntity>> execute(int candidateId) async {
    return await repository.unlockCandidateContact(candidateId);
  }
}
