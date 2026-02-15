import 'package:dartz/dartz.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../jobs/domain/entities/job_post_entity.dart';
import '../../domain/entities/company_entity.dart';
import '../../domain/repositories/company_repository.dart';
import '../datasources/company_remote_datasource.dart';

/// Implementation của CompanyRepository
class CompanyRepositoryImpl implements CompanyRepository {
  final CompanyRemoteDataSource remoteDataSource;

  CompanyRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<CompanyEntity>>> getCompanies() async {
    try {
      final companies = await remoteDataSource.getCompanies();
      return Right(companies);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(
        ServerFailure('Không thể lấy danh sách công ty: ${e.toString()}'),
      );
    }
  }

  @override
  Future<Either<Failure, CompanyEntity>> getCompanyById(int employerId) async {
    try {
      final company = await remoteDataSource.getCompanyById(employerId);
      return Right(company);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(
        ServerFailure('Không thể lấy thông tin công ty: ${e.toString()}'),
      );
    }
  }

  @override
  Future<Either<Failure, List<CompanyEntity>>> searchCompanies(
    String query,
  ) async {
    try {
      final companies = await remoteDataSource.searchCompanies(query);
      return Right(companies);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Không thể tìm kiếm công ty: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<JobPostEntity>>> getCompanyJobs(
    int employerId,
  ) async {
    try {
      final jobs = await remoteDataSource.getCompanyJobs(employerId);
      return Right(jobs);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(
        ServerFailure('Không thể lấy danh sách việc làm: ${e.toString()}'),
      );
    }
  }
}
