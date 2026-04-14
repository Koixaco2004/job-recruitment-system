import 'dart:typed_data';
import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/candidate_profile_entity.dart';
import '../entities/work_experience_entity.dart';
import '../entities/education_entity.dart';
import '../entities/certificate_entity.dart';
import '../entities/project_entity.dart';
import '../entities/job_type_entity.dart';
import '../entities/job_category_entity.dart';
import '../entities/skill_entity.dart';

abstract class ProfileRepository {
  Future<Either<Failure, CandidateProfileEntity>> getProfile();
  Future<Either<Failure, CandidateProfileEntity>> updateProfile(CandidateProfileEntity profile);
  Future<Either<Failure, String>> uploadCV(Uint8List bytes, String fileName);
  Future<Either<Failure, String?>> uploadAvatar(Uint8List bytes, String fileName);

  // Work Experiences
  Future<Either<Failure, List<WorkExperienceEntity>>> getWorkExperiences();
  Future<Either<Failure, WorkExperienceEntity>> createWorkExperience(WorkExperienceEntity exp);
  Future<Either<Failure, WorkExperienceEntity>> updateWorkExperience(int id, WorkExperienceEntity exp);
  Future<Either<Failure, void>> deleteWorkExperience(int id);

  // Educations
  Future<Either<Failure, List<EducationEntity>>> getEducations();
  Future<Either<Failure, EducationEntity>> createEducation(EducationEntity edu);
  Future<Either<Failure, EducationEntity>> updateEducation(int id, EducationEntity edu);
  Future<Either<Failure, void>> deleteEducation(int id);

  // Certificates
  Future<Either<Failure, List<CertificateEntity>>> getCertificates();
  Future<Either<Failure, CertificateEntity>> createCertificate({
    required String name,
    Uint8List? imageBytes,
    String? fileName,
  });
  Future<Either<Failure, CertificateEntity>> updateCertificate({
    required int id,
    required String name,
    Uint8List? imageBytes,
    String? fileName,
  });
  Future<Either<Failure, void>> deleteCertificate(int id);
  // Projects
  Future<Either<Failure, List<ProjectEntity>>> getProjects();
  Future<Either<Failure, ProjectEntity>> createProject(ProjectEntity project);
  Future<Either<Failure, ProjectEntity>> updateProject(int id, ProjectEntity project);
  Future<Either<Failure, void>> deleteProject(int id);

  Future<Either<Failure, List<JobTypeEntity>>> getJobTypes();

  // Job Categories
  Future<Either<Failure, List<JobCategoryEntity>>> getJobCategoriesMetadata();
  Future<Either<Failure, List<CandidateJobCategoryEntity>>> getCandidateJobCategories();
  Future<Either<Failure, void>> addCandidateJobCategories(List<int> categoryIds);
  Future<Either<Failure, void>> deleteCandidateJobCategory(int mappingId);

  /// Skill Methods
  Future<Either<Failure, List<SkillEntity>>> searchSkills(String query);
  Future<Either<Failure, List<CandidateSkillEntity>>> getCandidateSkills();
  Future<Either<Failure, void>> addCandidateSkills(List<dynamic> skills);
  Future<Either<Failure, void>> deleteCandidateSkill(int mappingId);
  Future<Either<Failure, void>> parseCv();
}
