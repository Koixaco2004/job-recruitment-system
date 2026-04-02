import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/job_post_entity.dart';
import '../repositories/job_repository.dart';
import '../../../../core/models/paginated_response.dart';

class GetEmployerJobsUseCase {
  final JobRepository repository;

  GetEmployerJobsUseCase(this.repository);

  Future<Either<Failure, PaginatedResponse<JobPostEntity>>> call({
    int page = 1,
    int limit = 10,
    String? status,
  }) async {
    return await repository.getMyJobsForEmployer(
      page: page,
      limit: limit,
      status: status,
    );
  }
}
