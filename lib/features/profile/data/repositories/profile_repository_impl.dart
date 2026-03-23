import 'dart:typed_data';
import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/candidate_profile_entity.dart';
import '../../../../core/error/exceptions.dart';
import '../../domain/repositories/profile_repository.dart';
import '../datasources/profile_remote_datasource.dart';
import '../models/candidate_profile_model.dart';
import '../../../../core/services/cloudinary_service.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  final ProfileRemoteDataSource remoteDataSource;
  final CloudinaryService cloudinaryService;

  ProfileRepositoryImpl({
    required this.remoteDataSource,
    required this.cloudinaryService,
  });

  @override
  Future<Either<Failure, CandidateProfileEntity>> getProfile() async {
    try {
      final profile = await remoteDataSource.getProfile();
      return Right(profile);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on AuthenticationException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Không thể tải hồ sơ: $e'));
    }
  }

  @override
  Future<Either<Failure, CandidateProfileEntity>> updateProfile(
    CandidateProfileEntity profile,
  ) async {
    try {
      final model = CandidateProfileModel.fromEntity(profile);
      final updated = await remoteDataSource.updateProfile(model);
      return Right(updated);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on AuthenticationException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Không thể cập nhật hồ sơ: $e'));
    }
  }

  @override
  Future<Either<Failure, String>> uploadCV(
    Uint8List bytes,
    String fileName,
  ) async {
    try {
      final url = await cloudinaryService.uploadFileBytes(bytes, fileName);
      return Right(url);
    } catch (e) {
      return Left(ServerFailure('Không thể upload CV: $e'));
    }
  }
}
