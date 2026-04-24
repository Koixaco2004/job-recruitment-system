import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/job_level_entity.dart';
import '../repositories/metadata_repository.dart';

class GetJobLevelsUseCase {
  final MetadataRepository repository;

  GetJobLevelsUseCase(this.repository);

  Future<Either<Failure, List<JobLevelEntity>>> call() async {
    return await repository.getJobLevels();
  }
}
