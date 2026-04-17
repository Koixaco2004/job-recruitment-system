import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/saved_candidate_entity.dart';
import '../repositories/headhunting_repository.dart';

class GetSavedCandidatesUseCase {
  final HeadhuntingRepository repository;

  GetSavedCandidatesUseCase({required this.repository});

  Future<Either<Failure, List<SavedCandidateEntity>>> execute() async {
    return await repository.getSavedCandidates();
  }
}
