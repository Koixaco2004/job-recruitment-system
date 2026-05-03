import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/headhunting_candidate_entity.dart';
import '../entities/candidate_detail_entity.dart';
import '../entities/candidate_invitation_entity.dart';
import '../entities/employer_invitation_entity.dart';
import '../entities/saved_candidate_entity.dart';
import '../entities/headhunting_quota_entity.dart';
import '../../data/models/employer_dashboard_stats_model.dart';
import '../../data/models/job_detailed_stats_model.dart';
import '../entities/suggested_candidates_response_entity.dart';

abstract class HeadhuntingRepository {
  Future<Either<Failure, SuggestedCandidatesResponseEntity>> getSuggestedCandidates(int jobId);
  
  Future<Either<Failure, Map<String, dynamic>>> searchCandidates({
    String? keyword,
    int? provinceId,
    int? minExperience,
    List<int>? categoryIds,
    List<int>? skillIds,
    int? jobTypeId,
    int? salaryMin,
    int? salaryMax,
    String? sortBy,
    String? sortOrder,
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

  // Employer Side
  Future<Either<Failure, List<EmployerInvitationEntity>>> getEmployerInvitations();
  Future<Either<Failure, bool>> saveCandidate(int candidateId, {String? note});
  Future<Either<Failure, bool>> unsaveCandidate(int candidateId);
  Future<Either<Failure, List<SavedCandidateEntity>>> getSavedCandidates();

  Future<Either<Failure, EmployerDashboardStatsModel>> getDashboardStats({int expiringSoonDays = 7});
  Future<Either<Failure, JobDetailedStatsModel>> getJobDetailedStats(int jobId);

  Future<Either<Failure, HeadhuntingQuotaEntity>> getHeadhuntingQuota();
  Future<Either<Failure, CandidateDetailEntity>> unlockCandidateContact(int candidateId);
}
