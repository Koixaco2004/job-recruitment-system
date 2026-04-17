import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../repositories/headhunting_repository.dart';

class SaveCandidateUseCase {
  final HeadhuntingRepository repository;

  SaveCandidateUseCase({required this.repository});

  Future<Either<Failure, bool>> call(int candidateId, {String? note}) async {
    return await repository.saveCandidate(candidateId, note: note);
  }
}
