import 'dart:typed_data';
import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/candidate_profile_entity.dart';
import '../../domain/entities/work_experience_entity.dart';
import '../../domain/entities/education_entity.dart';
import '../../domain/entities/certificate_entity.dart';
import '../../domain/entities/project_entity.dart';
import '../../domain/entities/job_type_entity.dart';
import '../../domain/entities/job_category_entity.dart';
import '../../domain/entities/skill_entity.dart';
import '../../../../core/error/exceptions.dart';
import '../../domain/repositories/profile_repository.dart';
import '../datasources/profile_remote_datasource.dart';
import '../models/candidate_profile_model.dart';
import '../models/work_experience_model.dart';
import '../models/education_model.dart';
import '../models/project_model.dart';
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

  @override
  Future<Either<Failure, String?>> uploadAvatar(
    Uint8List bytes,
    String fileName,
  ) async {
    try {
      final url = await remoteDataSource.uploadAvatar(bytes, fileName);
      return Right(url);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Không thể upload avatar: $e'));
    }
  }


  // ─── Work Experiences ──────────────────────────────────────────

  @override
  Future<Either<Failure, List<WorkExperienceEntity>>> getWorkExperiences() async {
    try {
      final list = await remoteDataSource.getWorkExperiences();
      final entities = list.map((e) => e as WorkExperienceEntity).toList();
      return Right(entities);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on AuthenticationException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Lỗi: $e'));
    }
  }

  @override
  Future<Either<Failure, WorkExperienceEntity>> createWorkExperience(WorkExperienceEntity exp) async {
    try {
      final model = WorkExperienceModel.fromEntity(exp);
      final result = await remoteDataSource.createWorkExperience(model);
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on AuthenticationException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Lỗi: $e'));
    }
  }

  @override
  Future<Either<Failure, WorkExperienceEntity>> updateWorkExperience(int id, WorkExperienceEntity exp) async {
    try {
      final model = WorkExperienceModel.fromEntity(exp);
      final result = await remoteDataSource.updateWorkExperience(id, model);
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on AuthenticationException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Lỗi: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteWorkExperience(int id) async {
    try {
      await remoteDataSource.deleteWorkExperience(id);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on AuthenticationException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Lỗi: $e'));
    }
  }

  // ─── Educations ─────────────────────────────────────────────────────

  @override
  Future<Either<Failure, List<EducationEntity>>> getEducations() async {
    try {
      final list = await remoteDataSource.getEducations();
      final entities = list.map((e) => e as EducationEntity).toList();
      return Right(entities);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on AuthenticationException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Lỗi: $e'));
    }
  }

  @override
  Future<Either<Failure, EducationEntity>> createEducation(EducationEntity edu) async {
    try {
      final model = EducationModel.fromEntity(edu);
      final result = await remoteDataSource.createEducation(model);
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on AuthenticationException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Lỗi: $e'));
    }
  }

  @override
  Future<Either<Failure, EducationEntity>> updateEducation(int id, EducationEntity edu) async {
    try {
      final model = EducationModel.fromEntity(edu);
      final result = await remoteDataSource.updateEducation(id, model);
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on AuthenticationException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Lỗi: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteEducation(int id) async {
    try {
      await remoteDataSource.deleteEducation(id);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on AuthenticationException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Lỗi: $e'));
    }
  }

  // ─── Certificates ───────────────────────────────────────────────────

  @override
  Future<Either<Failure, List<CertificateEntity>>> getCertificates() async {
    try {
      final list = await remoteDataSource.getCertificates();
      final entities = list.map((e) => e as CertificateEntity).toList();
      return Right(entities);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on AuthenticationException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Lỗi: $e'));
    }
  }

  @override
  Future<Either<Failure, CertificateEntity>> createCertificate({
    required String name,
    Uint8List? imageBytes,
    String? fileName,
  }) async {
    try {
      final result = await remoteDataSource.createCertificate(
        name: name,
        imageBytes: imageBytes,
        fileName: fileName,
      );
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on AuthenticationException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Lỗi: $e'));
    }
  }

  @override
  Future<Either<Failure, CertificateEntity>> updateCertificate({
    required int id,
    required String name,
    Uint8List? imageBytes,
    String? fileName,
  }) async {
    try {
      final result = await remoteDataSource.updateCertificate(
        id: id,
        name: name,
        imageBytes: imageBytes,
        fileName: fileName,
      );
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on AuthenticationException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Lỗi: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteCertificate(int id) async {
    try {
      await remoteDataSource.deleteCertificate(id);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on AuthenticationException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Lỗi: $e'));
    }
  }

  // ─── Projects ──────────────────────────────────────────────────────

  @override
  Future<Either<Failure, List<ProjectEntity>>> getProjects() async {
    try {
      final list = await remoteDataSource.getProjects();
      final entities = list.map((e) => e as ProjectEntity).toList();
      return Right(entities);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on AuthenticationException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Lỗi: $e'));
    }
  }

  @override
  Future<Either<Failure, ProjectEntity>> createProject(ProjectEntity project) async {
    try {
      final model = ProjectModel.fromEntity(project);
      final result = await remoteDataSource.createProject(model);
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on AuthenticationException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Lỗi: $e'));
    }
  }

  @override
  Future<Either<Failure, ProjectEntity>> updateProject(int id, ProjectEntity project) async {
    try {
      final model = ProjectModel.fromEntity(project);
      final result = await remoteDataSource.updateProject(id, model);
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on AuthenticationException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Lỗi: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteProject(int id) async {
    try {
      await remoteDataSource.deleteProject(id);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on AuthenticationException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Lỗi: $e'));
    }
  }

  @override
  Future<Either<Failure, List<JobTypeEntity>>> getJobTypes() async {
    try {
      final result = await remoteDataSource.getJobTypes();
      // Chuyển đổi List<JobTypeModel> sang List<JobTypeEntity> để tránh lỗi type mismatch ở runtime
      final entities = result.map((e) => e as JobTypeEntity).toList();
      return Right(entities);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on AuthenticationException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Lỗi: $e'));
    }
  }

  @override
  Future<Either<Failure, List<JobCategoryEntity>>> getJobCategoriesMetadata() async {
    try {
      final result = await remoteDataSource.getJobCategoriesMetadata();
      // Chuyển đổi List<JobCategoryModel> sang List<JobCategoryEntity> để tránh lỗi type mismatch ở runtime
      final entities = result.map((e) => e as JobCategoryEntity).toList();
      return Right(entities);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on AuthenticationException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Lỗi: $e'));
    }
  }

  @override
  Future<Either<Failure, List<CandidateJobCategoryEntity>>> getCandidateJobCategories() async {
    try {
      final result = await remoteDataSource.getCandidateJobCategories();
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on AuthenticationException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Lỗi: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> addCandidateJobCategories(List<int> categoryIds) async {
    try {
      await remoteDataSource.addCandidateJobCategories(categoryIds);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on AuthenticationException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Lỗi: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteCandidateJobCategory(int mappingId) async {
    try {
      await remoteDataSource.deleteCandidateJobCategory(mappingId);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on AuthenticationException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  // ─── Skills ───────────────────────────────────────────────────────────

  @override
  Future<Either<Failure, List<SkillEntity>>> searchSkills(String query) async {
    try {
      final results = await remoteDataSource.searchSkills(query);
      final entities = results.map((e) => e as SkillEntity).toList();
      return Right(entities);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<CandidateSkillEntity>>> getCandidateSkills() async {
    try {
      final results = await remoteDataSource.getCandidateSkills();
      final entities = results.map((e) => e as CandidateSkillEntity).toList();
      return Right(entities);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> addCandidateSkills(List<dynamic> skills) async {
    try {
      await remoteDataSource.addCandidateSkills(skills);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteCandidateSkill(int mappingId) async {
    try {
      await remoteDataSource.deleteCandidateSkill(mappingId);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> parseCv() async {
    try {
      await remoteDataSource.parseCv();
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on AuthenticationException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Lỗi khi phân tích CV: $e'));
    }
  }
}
