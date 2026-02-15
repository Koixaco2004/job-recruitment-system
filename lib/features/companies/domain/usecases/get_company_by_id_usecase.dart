import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/company_entity.dart';
import '../repositories/company_repository.dart';

/// Use case để lấy chi tiết công ty theo ID
class GetCompanyByIdUseCase {
  final CompanyRepository repository;

  GetCompanyByIdUseCase(this.repository);

  Future<Either<Failure, CompanyEntity>> call(int employerId) async {
    return await repository.getCompanyById(employerId);
  }
}
