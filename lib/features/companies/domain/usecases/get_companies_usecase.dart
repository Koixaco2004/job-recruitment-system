import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/company_entity.dart';
import '../repositories/company_repository.dart';

/// Use case để lấy danh sách tất cả công ty
class GetCompaniesUseCase {
  final CompanyRepository repository;

  GetCompaniesUseCase(this.repository);

  Future<Either<Failure, List<CompanyEntity>>> call() async {
    return await repository.getCompanies();
  }
}
