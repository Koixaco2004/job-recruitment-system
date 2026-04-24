import 'package:dartz/dartz.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/province_entity.dart';
import '../../domain/entities/job_category_entity.dart';
import '../../domain/entities/job_level_entity.dart';
import '../../../profile/domain/entities/skill_entity.dart';
import '../../domain/repositories/metadata_repository.dart';
import '../datasources/metadata_remote_datasource.dart';

class MetadataRepositoryImpl implements MetadataRepository {
  final MetadataRemoteDataSource remoteDataSource;

  MetadataRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<ProvinceEntity>>> getProvinces() async {
    try {
      final provinces = await remoteDataSource.getProvinces();
      return Right(provinces);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Lỗi truy xuất tỉnh thành: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<JobCategoryEntity>>> getJobCategories() async {
    try {
      final categories = await remoteDataSource.getJobCategories();
      return Right(categories);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Lỗi truy xuất ngành nghề: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<JobLevelEntity>>> getJobLevels() async {
    try {
      final levels = await remoteDataSource.getJobLevels();
      return Right(levels);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Lỗi truy xuất cấp bậc: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<SkillEntity>>> searchSkills(String query) async {
    try {
      final skills = await remoteDataSource.searchSkills(query);
      return Right(skills.cast<SkillEntity>());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Lỗi tìm kiếm kỹ năng: ${e.toString()}'));
    }
  }
}
