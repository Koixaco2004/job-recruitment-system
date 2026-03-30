import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/province_entity.dart';
import '../entities/job_category_entity.dart';

abstract class MetadataRepository {
  Future<Either<Failure, List<ProvinceEntity>>> getProvinces();
  Future<Either<Failure, List<JobCategoryEntity>>> getJobCategories();
}
