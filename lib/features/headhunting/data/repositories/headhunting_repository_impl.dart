import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/headhunting_candidate_entity.dart';
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
}
