import 'dart:typed_data';
import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/employer_entity.dart';

abstract class EmployerRepository {
  Future<Either<Failure, EmployerEntity>> getProfile();
  
  Future<Either<Failure, Unit>> setupCompany({
    required String fullName,
    required String phoneContact,
    required String companyName,
    required int categoryId,
    int? provinceId,
    String? address,
  });

  Future<Either<Failure, EmployerEntity>> updateProfile({
    required String fullName,
    required String phoneContact,
  });

  Future<Either<Failure, String>> uploadAvatar({
    required Uint8List imageBytes,
    required String fileName,
  });

  // Member Management
  Future<Either<Failure, List<EmployerEntity>>> getMembers();
  Future<Either<Failure, void>> addMember({
    required String email,
    required String fullName,
    required String role,
    required String password,
  });
  Future<Either<Failure, void>> removeMember(int id);
}
