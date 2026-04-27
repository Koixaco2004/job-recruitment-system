import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/company_entity.dart';
import '../repositories/company_repository.dart';

class GetCompanyBySlugUseCase {
  final CompanyRepository repository;

  GetCompanyBySlugUseCase(this.repository);

  Future<Either<Failure, CompanyEntity>> call(String slug) async {
    return await repository.getCompanyBySlug(slug);
  }
}
