import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/company_entity.dart';
import '../repositories/company_repository.dart';

/// Use case để tìm kiếm công ty theo tên
class SearchCompaniesUseCase {
  final CompanyRepository repository;

  SearchCompaniesUseCase(this.repository);

  Future<Either<Failure, List<CompanyEntity>>> call(String query) async {
    return await repository.searchCompanies(query);
  }
}
