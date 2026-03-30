import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/employer_entity.dart';
import '../repositories/employer_repository.dart';

class GetEmployerProfileUseCase {
  final EmployerRepository repository;

  GetEmployerProfileUseCase(this.repository);

  Future<Either<Failure, EmployerEntity>> call() async {
    return await repository.getProfile();
  }
}

class SetupCompanyUseCase {
  final EmployerRepository repository;

  SetupCompanyUseCase(this.repository);

  Future<Either<Failure, Unit>> call({
    required String fullName,
    required String phoneContact,
    required String companyName,
    required int categoryId,
    int? provinceId,
    String? address,
  }) async {
    return await repository.setupCompany(
      fullName: fullName,
      phoneContact: phoneContact,
      companyName: companyName,
      categoryId: categoryId,
      provinceId: provinceId,
      address: address,
    );
  }
}
