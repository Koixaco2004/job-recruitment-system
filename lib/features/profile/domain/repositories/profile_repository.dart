import 'dart:typed_data';
import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/candidate_profile_entity.dart';
import '../entities/work_experience_entity.dart';
import '../entities/education_entity.dart';

/// Abstract repository cho Profile
abstract class ProfileRepository {
  Future<Either<Failure, CandidateProfileEntity>> getProfile();
  Future<Either<Failure, CandidateProfileEntity>> updateProfile(CandidateProfileEntity profile);
  Future<Either<Failure, String>> uploadCV(Uint8List bytes, String fileName);

  // ─── Work Experiences ───────────────────────────────────
  Future<Either<Failure, List<WorkExperienceEntity>>> getWorkExperiences();
  Future<Either<Failure, WorkExperienceEntity>> createWorkExperience(WorkExperienceEntity exp);
  Future<Either<Failure, WorkExperienceEntity>> updateWorkExperience(int id, WorkExperienceEntity exp);
  Future<Either<Failure, void>> deleteWorkExperience(int id);

  // ─── Educations ─────────────────────────────────────────
  Future<Either<Failure, List<EducationEntity>>> getEducations();
  Future<Either<Failure, EducationEntity>> createEducation(EducationEntity edu);
  Future<Either<Failure, EducationEntity>> updateEducation(int id, EducationEntity edu);
  Future<Either<Failure, void>> deleteEducation(int id);
}
