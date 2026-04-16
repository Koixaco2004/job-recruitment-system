import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/headhunting_candidate_entity.dart';
import '../entities/candidate_detail_entity.dart';
import '../entities/candidate_invitation_entity.dart';

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

  Future<Either<Failure, CandidateDetailEntity>> getCandidateDetail(int id);

  Future<Either<Failure, bool>> sendInvitation({
    required int jobId,
    required int candidateId,
    required String message,
  });

  // Candidate Side
  Future<Either<Failure, List<CandidateInvitationEntity>>> getCandidateInvitations();
  Future<Either<Failure, bool>> acceptInvitation(int id);
  Future<Either<Failure, bool>> declineInvitation(int id);
}
