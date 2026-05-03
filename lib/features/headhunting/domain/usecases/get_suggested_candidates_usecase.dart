import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/suggested_candidates_response_entity.dart';
import '../repositories/headhunting_repository.dart';

class GetSuggestedCandidatesUseCase {
  final HeadhuntingRepository repository;

  GetSuggestedCandidatesUseCase(this.repository);

  Future<Either<Failure, SuggestedCandidatesResponseEntity>> execute(int jobId) {
    return repository.getSuggestedCandidates(jobId);
  }
}
