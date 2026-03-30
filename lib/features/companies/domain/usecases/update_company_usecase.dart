import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/company_entity.dart';
import '../repositories/company_repository.dart';

class UpdateCompanyUseCase {
  final CompanyRepository repository;

  UpdateCompanyUseCase(this.repository);

  Future<Either<Failure, CompanyEntity>> call({
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
    return await repository.updateCompanyProfile(
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
  }
}
