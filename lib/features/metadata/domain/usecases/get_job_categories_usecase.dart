import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/job_category_entity.dart';
import '../repositories/metadata_repository.dart';

class GetJobCategoriesUseCase {
  final MetadataRepository repository;

  GetJobCategoriesUseCase(this.repository);

  Future<Either<Failure, List<JobCategoryEntity>>> call() async {
    return await repository.getJobCategories();
  }
}
