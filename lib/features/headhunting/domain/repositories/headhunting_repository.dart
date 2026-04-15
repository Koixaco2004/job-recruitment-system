import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/headhunting_candidate_entity.dart';

abstract class HeadhuntingRepository {
  Future<Either<Failure, List<HeadhuntingCandidateEntity>>> getSuggestedCandidates(int jobId);
  
  // Later we can add searchCandidates, saveCandidate, etc.
}
