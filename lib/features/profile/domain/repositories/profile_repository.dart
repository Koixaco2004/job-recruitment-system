import 'dart:typed_data';
import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/candidate_profile_entity.dart';

/// Abstract repository cho Profile
abstract class ProfileRepository {
  /// Lấy hồ sơ ứng viên
  Future<Either<Failure, CandidateProfileEntity>> getProfile();

  /// Cập nhật hồ sơ ứng viên
  Future<Either<Failure, CandidateProfileEntity>> updateProfile(
    CandidateProfileEntity profile,
  );

  /// Upload CV bằng bytes và trả về URL
  Future<Either<Failure, String>> uploadCV(Uint8List bytes, String fileName);
}
