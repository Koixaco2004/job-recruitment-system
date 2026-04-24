import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/province_entity.dart';
import '../entities/job_category_entity.dart';
import '../entities/job_level_entity.dart';
import '../../../profile/domain/entities/skill_entity.dart';

abstract class MetadataRepository {
  Future<Either<Failure, List<ProvinceEntity>>> getProvinces();
  Future<Either<Failure, List<JobCategoryEntity>>> getJobCategories();
  Future<Either<Failure, List<JobLevelEntity>>> getJobLevels();
  Future<Either<Failure, List<SkillEntity>>> searchSkills(String query);
}
