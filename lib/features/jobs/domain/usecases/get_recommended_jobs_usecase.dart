import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/models/paginated_response.dart';
import '../entities/job_post_entity.dart';
import '../repositories/job_repository.dart';

class GetRecommendedJobsUseCase {
  final JobRepository repository;

  GetRecommendedJobsUseCase(this.repository);

  Future<Either<Failure, PaginatedResponse<JobPostEntity>>> call({
    int page = 1,
    int limit = 20,
  }) {
    return repository.getRecommendedJobs(page: page, limit: limit);
  }
}
