import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../jobs/domain/entities/job_post_entity.dart';
import '../entities/company_entity.dart';

/// Repository interface cho Companies
abstract class CompanyRepository {
  /// Lấy danh sách tất cả công ty
  Future<Either<Failure, List<CompanyEntity>>> getCompanies();

  /// Lấy chi tiết công ty theo ID
  Future<Either<Failure, CompanyEntity>> getCompanyById(int employerId);

  /// Tìm kiếm công ty theo tên
  Future<Either<Failure, List<CompanyEntity>>> searchCompanies(String query);

  /// Lấy danh sách việc làm của công ty
  Future<Either<Failure, List<JobPostEntity>>> getCompanyJobs(int employerId);
}
