import 'dart:typed_data';
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

class UpdateEmployerProfileUseCase {
  final EmployerRepository repository;

  UpdateEmployerProfileUseCase(this.repository);

  Future<Either<Failure, EmployerEntity>> call({
    required String fullName,
    required String phoneContact,
  }) async {
    return await repository.updateProfile(
      fullName: fullName,
      phoneContact: phoneContact,
    );
  }
}

class UploadEmployerAvatarUseCase {
  final EmployerRepository repository;

  UploadEmployerAvatarUseCase(this.repository);

  Future<Either<Failure, String>> call({
    required Uint8List imageBytes,
    required String fileName,
  }) async {
    return await repository.uploadAvatar(
      imageBytes: imageBytes,
      fileName: fileName,
    );
  }
}

class GetMembersUseCase {
  final EmployerRepository repository;

  GetMembersUseCase(this.repository);

  Future<Either<Failure, List<EmployerEntity>>> call() async {
    return await repository.getMembers();
  }
}

class AddMemberUseCase {
  final EmployerRepository repository;

  AddMemberUseCase(this.repository);

  Future<Either<Failure, void>> call({
    required String email,
    required String fullName,
    required String role,
    required String password,
  }) async {
    return await repository.addMember(
      email: email,
      fullName: fullName,
      role: role,
      password: password,
    );
  }
}

class RemoveMemberUseCase {
  final EmployerRepository repository;

  RemoveMemberUseCase(this.repository);

  Future<Either<Failure, void>> call(int id) async {
    return await repository.removeMember(id);
  }
}
