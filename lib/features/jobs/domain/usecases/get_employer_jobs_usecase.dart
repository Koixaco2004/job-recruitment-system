import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../repositories/job_repository.dart';

class GetEmployerJobsUseCase {
  final JobRepository repository;

  GetEmployerJobsUseCase(this.repository);

  Future<Either<Failure, Map<String, dynamic>>> call({
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
