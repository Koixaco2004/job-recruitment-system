import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../repositories/headhunting_repository.dart';

class UnsaveCandidateUseCase {
  final HeadhuntingRepository repository;

  UnsaveCandidateUseCase({required this.repository});

  Future<Either<Failure, bool>> call(int candidateId) async {
    return await repository.unsaveCandidate(candidateId);
  }
}
