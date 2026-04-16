import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/headhunting_candidate_entity.dart';
import '../../domain/entities/candidate_detail_entity.dart';
import '../../domain/entities/candidate_invitation_entity.dart';
import '../../domain/repositories/headhunting_repository.dart';
import '../datasources/headhunting_remote_datasource.dart';

class HeadhuntingRepositoryImpl implements HeadhuntingRepository {
  final HeadhuntingRemoteDataSource remoteDataSource;

  HeadhuntingRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<HeadhuntingCandidateEntity>>> getSuggestedCandidates(int jobId) async {
    try {
      final candidates = await remoteDataSource.getSuggestedCandidates(jobId);
      return Right(candidates);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> searchCandidates({
    String? keyword,
    int? provinceId,
    int? yearsOfExperience,
    int? jobCategoryId,
    int? jobTypeId,
    int page = 1,
  }) async {
    try {
      final result = await remoteDataSource.searchCandidates(
        keyword: keyword,
        provinceId: provinceId,
        yearsOfExperience: yearsOfExperience,
        jobCategoryId: jobCategoryId,
        jobTypeId: jobTypeId,
        page: page,
      );
      return Right(result);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, CandidateDetailEntity>> getCandidateDetail(int id) async {
    try {
      final detail = await remoteDataSource.getCandidateDetail(id);
      return Right(detail);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> sendInvitation({
    required int jobId,
    required int candidateId,
    required String message,
  }) async {
    try {
      final success = await remoteDataSource.sendInvitation(
        jobId: jobId,
        candidateId: candidateId,
        message: message,
      );
      return Right(success);
    } catch (e) {
      final message = e.toString().replaceAll('Exception: ', '');
      return Left(ServerFailure(message));
    }
  }

  @override
  Future<Either<Failure, List<CandidateInvitationEntity>>> getCandidateInvitations() async {
    try {
      final invitations = await remoteDataSource.getCandidateInvitations();
      return Right(invitations);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> acceptInvitation(int id) async {
    try {
      final success = await remoteDataSource.acceptInvitation(id);
      return Right(success);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> declineInvitation(int id) async {
    try {
      final success = await remoteDataSource.declineInvitation(id);
      return Right(success);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
