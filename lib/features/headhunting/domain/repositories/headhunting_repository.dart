import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/headhunting_candidate_entity.dart';

abstract class HeadhuntingRepository {
  Future<Either<Failure, List<HeadhuntingCandidateEntity>>> getSuggestedCandidates(int jobId);
  
  Future<Either<Failure, Map<String, dynamic>>> searchCandidates({
    String? keyword,
    int? provinceId,
    int? yearsOfExperience,
    int? jobCategoryId,
    int? jobTypeId,
    int page = 1,
  });
  
  // Later we can add saveCandidate, etc.
}
