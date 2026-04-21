import 'dart:typed_data';
import 'package:dartz/dartz.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../datasources/employer_remote_datasource.dart';
import '../../domain/repositories/employer_repository.dart';
import '../../domain/entities/employer_entity.dart';

class EmployerRepositoryImpl implements EmployerRepository {
  final EmployerRemoteDataSource remoteDataSource;

  EmployerRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, EmployerEntity>> getProfile() async {
    try {
      final profile = await remoteDataSource.getProfile();
      return Right(profile);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> setupCompany({
    required String fullName,
    required String phoneContact,
    required String companyName,
    required int categoryId,
    int? provinceId,
    String? address,
  }) async {
    try {
      await remoteDataSource.setupCompany(
        fullName: fullName,
        phoneContact: phoneContact,
        companyName: companyName,
        categoryId: categoryId,
        provinceId: provinceId,
        address: address,
      );
      return const Right(unit);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, EmployerEntity>> updateProfile({
    required String fullName,
    required String phoneContact,
  }) async {
    try {
      final updatedProfile = await remoteDataSource.updateProfile(
        fullName: fullName,
        phoneContact: phoneContact,
      );
      return Right(updatedProfile);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, String>> uploadAvatar({
    required Uint8List imageBytes,
    required String fileName,
  }) async {
    try {
      final url = await remoteDataSource.uploadAvatar(
        imageBytes: imageBytes,
        fileName: fileName,
      );
      return Right(url);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<EmployerEntity>>> getMembers() async {
    try {
      final members = await remoteDataSource.getMembers();
      return Right(members);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> addMember({
    required String email,
    required String fullName,
    required String role,
    required String password,
  }) async {
    try {
      await remoteDataSource.addMember(
        email: email,
        fullName: fullName,
        role: role,
        password: password,
      );
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> removeMember(int id) async {
    try {
      await remoteDataSource.removeMember(id);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
