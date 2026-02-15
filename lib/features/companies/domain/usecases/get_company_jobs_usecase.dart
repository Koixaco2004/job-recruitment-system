import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../jobs/domain/entities/job_post_entity.dart';
import '../repositories/company_repository.dart';

/// Use case để lấy danh sách việc làm của công ty
class GetCompanyJobsUseCase {
  final CompanyRepository repository;

  GetCompanyJobsUseCase(this.repository);

  Future<Either<Failure, List<JobPostEntity>>> call(int employerId) async {
    return await repository.getCompanyJobs(employerId);
  }
}
