import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../repositories/job_repository.dart';

/// Use case để lấy danh sách jobs
class GetJobsUseCase {
  final JobRepository repository;

  GetJobsUseCase(this.repository);

  /// Execute - lấy danh sách jobs với phân trang và lọc
  Future<Either<Failure, Map<String, dynamic>>> call({
    int page = 1,
    int limit = 10,
    String? keyword,
    int? provinceId,
    int? categoryId,
    int? jobTypeId,
  }) async {
    return await repository.getJobs(
      page: page,
      limit: limit,
      keyword: keyword,
      provinceId: provinceId,
      categoryId: categoryId,
      jobTypeId: jobTypeId,
    );
  }
}
