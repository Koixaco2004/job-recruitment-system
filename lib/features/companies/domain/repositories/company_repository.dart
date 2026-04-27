import 'dart:typed_data';
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

  /// Lấy chi tiết công ty theo Slug
  Future<Either<Failure, CompanyEntity>> getCompanyBySlug(String slug);

  /// Tìm kiếm công ty theo tên
  Future<Either<Failure, List<CompanyEntity>>> searchCompanies(String query);

  /// Lấy danh sách việc làm của công ty
  Future<Either<Failure, List<JobPostEntity>>> getCompanyJobs(String slug);

  // Employer - Company Profile Management
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
  });

  Future<Either<Failure, String>> uploadLogo(Uint8List bytes, String fileName);
  Future<Either<Failure, String>> uploadBanner(Uint8List bytes, String fileName);
  Future<Either<Failure, String>> uploadGalleryImage(
    Uint8List bytes,
    String fileName,
  );
  Future<Either<Failure, String>> uploadBusinessLicense(
    Uint8List bytes,
    String fileName,
  );
}
