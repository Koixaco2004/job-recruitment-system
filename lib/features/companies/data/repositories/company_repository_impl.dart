import 'dart:typed_data';
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
  Future<Either<Failure, CompanyEntity>> getCompanyBySlug(String slug) async {
    try {
      final company = await remoteDataSource.getCompanyBySlug(slug);
      return Right(company);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(
        ServerFailure('Không thể lấy thông tin công ty theo slug: ${e.toString()}'),
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
    String slug,
  ) async {
    try {
      final jobs = await remoteDataSource.getCompanyJobs(slug);
      return Right(jobs);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(
        ServerFailure('Không thể lấy danh sách việc làm: ${e.toString()}'),
      );
    }
  }

  @override
  Future<Either<Failure, CompanyEntity>> updateCompanyProfile({
    required String name,
    String? description,
    String? content,
    String? websiteUrl,
    String? address,
    int? provinceId,
    int? categoryId,
    String? emailContact,
    String? phoneContact,
    String? companySize,
    String? facebookUrl,
    String? linkedinUrl,
  }) async {
    try {
      final updated = await remoteDataSource.updateCompanyProfile(
        name: name,
        description: description,
        content: content,
        websiteUrl: websiteUrl,
        address: address,
        provinceId: provinceId,
        categoryId: categoryId,
        emailContact: emailContact,
        phoneContact: phoneContact,
        companySize: companySize,
        facebookUrl: facebookUrl,
        linkedinUrl: linkedinUrl,
      );
      return Right(updated);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, String>> uploadLogo(
    Uint8List bytes,
    String fileName,
  ) async {
    try {
      final url = await remoteDataSource.uploadLogo(bytes, fileName);
      return Right(url);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, String>> uploadBanner(
    Uint8List bytes,
    String fileName,
  ) async {
    try {
      final url = await remoteDataSource.uploadBanner(bytes, fileName);
      return Right(url);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, String>> uploadGalleryImage(
    Uint8List bytes,
    String fileName,
  ) async {
    try {
      final url = await remoteDataSource.uploadGalleryImage(bytes, fileName);
      return Right(url);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, String>> uploadBusinessLicense(
    Uint8List bytes,
    String fileName,
  ) async {
    try {
      final url = await remoteDataSource.uploadBusinessLicense(bytes, fileName);
      return Right(url);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
