import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/headhunting_candidate_entity.dart';
import '../repositories/headhunting_repository.dart';

class GetSuggestedCandidatesUseCase {
  final HeadhuntingRepository repository;

  GetSuggestedCandidatesUseCase(this.repository);

  Future<Either<Failure, List<HeadhuntingCandidateEntity>>> execute(int jobId) {
    return repository.getSuggestedCandidates(jobId);
  }
}
