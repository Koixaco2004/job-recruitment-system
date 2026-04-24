import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/job_post_entity.dart';
import '../repositories/job_repository.dart';
import '../../../../core/models/paginated_response.dart';

/// Use case để lấy danh sách jobs
class GetJobsUseCase {
  final JobRepository repository;

  GetJobsUseCase(this.repository);

  /// Execute - lấy danh sách jobs với phân trang và lọc
  Future<Either<Failure, PaginatedResponse<JobPostEntity>>> call({
    int page = 1,
    int limit = 10,
    String? keyword,
    int? provinceId,
    int? categoryId,
    int? jobTypeId,
    int? levelId,
    int? salaryMin,
    int? salaryMax,
    String? requiredDegree,
    int? maxYearsRequired,
    List<int>? skillIds,
  }) async {
    return await repository.getJobs(
      page: page,
      limit: limit,
      keyword: keyword,
      provinceId: provinceId,
      categoryId: categoryId,
      jobTypeId: jobTypeId,
      levelId: levelId,
      salaryMin: salaryMin,
      salaryMax: salaryMax,
      requiredDegree: requiredDegree,
      maxYearsRequired: maxYearsRequired,
      skillIds: skillIds,
    );
  }
}
