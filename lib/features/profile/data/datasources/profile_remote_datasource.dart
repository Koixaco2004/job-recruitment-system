import 'dart:typed_data';
import 'package:dio/dio.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/network/api_client.dart';
import '../models/candidate_profile_model.dart';
import '../models/work_experience_model.dart';
import '../models/education_model.dart';
import '../models/certificate_model.dart';
import '../models/project_model.dart';
import '../models/job_type_model.dart';
import '../models/job_category_model.dart';
import '../models/skill_model.dart';

/// Abstract interface cho Profile Data Source
abstract class ProfileRemoteDataSource {
  Future<CandidateProfileModel> getProfile();
  Future<CandidateProfileModel> updateProfile(CandidateProfileModel profile);
  // Work Experiences
  Future<List<WorkExperienceModel>> getWorkExperiences();
  Future<WorkExperienceModel> createWorkExperience(WorkExperienceModel exp);
  Future<WorkExperienceModel> updateWorkExperience(int id, WorkExperienceModel exp);
  Future<void> deleteWorkExperience(int id);
  // Educations
  Future<List<EducationModel>> getEducations();
  Future<EducationModel> createEducation(EducationModel edu);
  Future<EducationModel> updateEducation(int id, EducationModel edu);
  Future<void> deleteEducation(int id);
  // Certificates
  Future<List<CertificateModel>> getCertificates();
  Future<CertificateModel> createCertificate({
    required String name,
    Uint8List? imageBytes,
    String? fileName,
  });
  Future<CertificateModel> updateCertificate({
    required int id,
    required String name,
    Uint8List? imageBytes,
    String? fileName,
  });
  Future<void> deleteCertificate(int id);
  // Projects
  Future<List<ProjectModel>> getProjects();
  Future<ProjectModel> createProject(ProjectModel project);
  Future<ProjectModel> updateProject(int id, ProjectModel project);
  Future<void> deleteProject(int id);

  Future<List<JobTypeModel>> getJobTypes();

  // Job Categories
  Future<List<JobCategoryModel>> getJobCategoriesMetadata();
  Future<List<CandidateJobCategoryModel>> getCandidateJobCategories();
  Future<void> addCandidateJobCategories(List<int> categoryIds);
  Future<void> deleteCandidateJobCategory(int mappingId);

  // Skills
  Future<List<SkillModel>> searchSkills(String query);
  Future<List<CandidateSkillModel>> getCandidateSkills();
  Future<void> addCandidateSkills(List<dynamic> skills);
  Future<void> deleteCandidateSkill(int mappingId);
  Future<String?> uploadAvatar(Uint8List bytes, String fileName);
  Future<void> updateVisibility(bool isVisible);
  Future<void> parseCv();
}

/// Implementation gọi API thật
class ProfileRemoteDataSourceImpl implements ProfileRemoteDataSource {
  final ApiClient apiClient;

  ProfileRemoteDataSourceImpl({required this.apiClient});

  CandidateProfileModel? _cachedProfile;

  @override
  Future<CandidateProfileModel> getProfile() async {
    try {
      final response = await apiClient.dio.get('/api/candidates/profile');
      
      if (response.statusCode == 200) {
        final data = response.data;
        print('Profile Response: $data');
        // data có thể bọc trong data hoặc trả trực tiếp tuỳ backend, giả xử data gốc
        final Map<String, dynamic> responseData = data['data'] ?? data;
        _cachedProfile = CandidateProfileModel.fromJson(responseData);
        return _cachedProfile!;
      } else {
        throw ServerException('Không thể lấy thông tin hồ sơ cá nhân');
      }
    } on DioException catch (e) {
      print('DioException in getProfile: ${e.response?.data}');
      if (e.response?.statusCode == 401) {
        throw const AuthenticationException('Phiên đăng nhập hết hạn');
      } else if (e.response?.statusCode == 404) {
        throw ServerException('Không tìm thấy hồ sơ cá nhân');
      }
      throw ServerException(e.message ?? 'Lỗi kết nối server');
    } catch (e, stackTrace) {
      print('Error parsing profile: $e');
      print(stackTrace);
      if (e is ServerException || e is AuthenticationException) rethrow;
      throw ServerException('Đã xảy ra lỗi: ${e.toString()}');
    }
  }

  @override
  Future<CandidateProfileModel> updateProfile(
    CandidateProfileModel profile,
  ) async {
    try {
      final response = await apiClient.dio.put(
        '/api/candidates/profile',
        data: profile.toUpdateProfileDto(),
      );

      if (response.statusCode == 200) {
        // Cập nhật local cache
        _cachedProfile = profile;
        return _cachedProfile!;
      } else {
        throw ServerException('Cập nhật hồ sơ thất bại');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw const AuthenticationException('Phiên đăng nhập hết hạn');
      }
      throw ServerException(e.message ?? 'Lỗi kết nối server');
    } catch (e) {
      if (e is ServerException || e is AuthenticationException) rethrow;
      throw ServerException('Đã xảy ra lỗi: ${e.toString()}');
    }
  }

  // Fallback mock logic for missing APIs temporarily (Skills, Educations, Experiences...) 
  // currently we keep parsing them out if missing from GET call or fetch from other ones later

  // ─── Work Experiences ──────────────────────────────────────────────────

  @override
  Future<List<WorkExperienceModel>> getWorkExperiences() async {
    try {
      final response = await apiClient.dio.get('/api/candidates/work-experiences');
      if (response.statusCode == 200) {
        final data = response.data;
        final list = (data['data'] ?? data) as List;
        return list
            .map((e) => WorkExperienceModel.fromJson(e as Map<String, dynamic>))
            .toList();
      }
      throw ServerException('Không thể lấy danh sách kinh nghiệm');
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) throw const AuthenticationException('Phiên đăng nhập hết hạn');
      throw ServerException(e.message ?? 'Lỗi kết nối server');
    } catch (e) {
      if (e is ServerException || e is AuthenticationException) rethrow;
      throw ServerException('Lỗi: ${e.toString()}');
    }
  }

  @override
  Future<WorkExperienceModel> createWorkExperience(WorkExperienceModel exp) async {
    try {
      final response = await apiClient.dio.post(
        '/api/candidates/work-experiences',
        data: exp.toCreateDto(),
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data;
        return WorkExperienceModel.fromJson(data['data'] ?? data);
      }
      throw ServerException('Tạo kinh nghiệm thất bại');
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) throw const AuthenticationException('Phiên đăng nhập hết hạn');
      throw ServerException(e.message ?? 'Lỗi kết nối server');
    } catch (e) {
      if (e is ServerException || e is AuthenticationException) rethrow;
      throw ServerException('Lỗi: ${e.toString()}');
    }
  }

  @override
  Future<WorkExperienceModel> updateWorkExperience(int id, WorkExperienceModel exp) async {
    try {
      final response = await apiClient.dio.put(
        '/api/candidates/work-experiences/$id',
        data: exp.toUpdateDto(),
      );
      if (response.statusCode == 200) {
        final data = response.data;
        return WorkExperienceModel.fromJson(data['data'] ?? data);
      }
      throw ServerException('Cập nhật kinh nghiệm thất bại');
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) throw const AuthenticationException('Phiên đăng nhập hết hạn');
      throw ServerException(e.message ?? 'Lỗi kết nối server');
    } catch (e) {
      if (e is ServerException || e is AuthenticationException) rethrow;
      throw ServerException('Lỗi: ${e.toString()}');
    }
  }

  @override
  Future<void> deleteWorkExperience(int id) async {
    try {
      final response = await apiClient.dio.delete('/api/candidates/work-experiences/$id');
      if (response.statusCode != 200 && response.statusCode != 204) {
        throw ServerException('Xóa kinh nghiệm thất bại');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) throw const AuthenticationException('Phiên đăng nhập hết hạn');
      throw ServerException(e.message ?? 'Lỗi kết nối server');
    } catch (e) {
      if (e is ServerException || e is AuthenticationException) rethrow;
      throw ServerException('Lỗi: ${e.toString()}');
    }
  }

  // ─── Educations ──────────────────────────────────────────────────────

  @override
  Future<List<EducationModel>> getEducations() async {
    try {
      final response = await apiClient.dio.get('/api/candidates/educations');
      if (response.statusCode == 200) {
        final data = response.data;
        final list = (data['data'] ?? data) as List;
        return list
            .map((e) => EducationModel.fromJson(e as Map<String, dynamic>))
            .toList();
      }
      throw ServerException('Không thể lấy danh sách học vấn');
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) throw const AuthenticationException('Phiên đăng nhập hết hạn');
      throw ServerException(e.message ?? 'Lỗi kết nối server');
    } catch (e) {
      if (e is ServerException || e is AuthenticationException) rethrow;
      throw ServerException('Lỗi: ${e.toString()}');
    }
  }

  @override
  Future<EducationModel> createEducation(EducationModel edu) async {
    try {
      final response = await apiClient.dio.post(
        '/api/candidates/educations',
        data: edu.toCreateDto(),
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data;
        return EducationModel.fromJson(data['data'] ?? data);
      }
      throw ServerException('Tạo học vấn thất bại');
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) throw const AuthenticationException('Phiên đăng nhập hết hạn');
      throw ServerException(e.message ?? 'Lỗi kết nối server');
    } catch (e) {
      if (e is ServerException || e is AuthenticationException) rethrow;
      throw ServerException('Lỗi: ${e.toString()}');
    }
  }

  @override
  Future<EducationModel> updateEducation(int id, EducationModel edu) async {
    try {
      final response = await apiClient.dio.put(
        '/api/candidates/educations/$id',
        data: edu.toUpdateDto(),
      );
      if (response.statusCode == 200) {
        final data = response.data;
        return EducationModel.fromJson(data['data'] ?? data);
      }
      throw ServerException('Cập nhật học vấn thất bại');
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) throw const AuthenticationException('Phiên đăng nhập hết hạn');
      throw ServerException(e.message ?? 'Lỗi kết nối server');
    } catch (e) {
      if (e is ServerException || e is AuthenticationException) rethrow;
      throw ServerException('Lỗi: ${e.toString()}');
    }
  }

  @override
  Future<void> deleteEducation(int id) async {
    try {
      final response = await apiClient.dio.delete('/api/candidates/educations/$id');
      if (response.statusCode != 200 && response.statusCode != 204) {
        throw ServerException('Xóa học vấn thất bại');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) throw const AuthenticationException('Phiên đăng nhập hết hạn');
      throw ServerException(e.message ?? 'Lỗi kết nối server');
    } catch (e) {
      if (e is ServerException || e is AuthenticationException) rethrow;
      throw ServerException('Lỗi: ${e.toString()}');
    }
  }

  // ─── Certificates ────────────────────────────────────────────────────

  @override
  Future<List<CertificateModel>> getCertificates() async {
    try {
      final response = await apiClient.dio.get('/api/candidates/certificates');
      if (response.statusCode == 200) {
        final data = response.data;
        final list = (data['data'] ?? data) as List;
        return list
            .map((e) => CertificateModel.fromJson(e as Map<String, dynamic>))
            .toList();
      }
      throw ServerException('Không thể lấy danh sách chứng chỉ');
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) throw const AuthenticationException('Phiên đăng nhập hết hạn');
      throw ServerException(e.message ?? 'Lỗi kết nối server');
    } catch (e) {
      if (e is ServerException || e is AuthenticationException) rethrow;
      throw ServerException('Lỗi: ${e.toString()}');
    }
  }

  @override
  Future<CertificateModel> createCertificate({
    required String name,
    Uint8List? imageBytes,
    String? fileName,
  }) async {
    try {
      final formDataMap = <String, dynamic>{
        'name': name,
      };

      if (imageBytes != null && fileName != null) {
        formDataMap['image'] = MultipartFile.fromBytes(
          imageBytes,
          filename: fileName,
        );
      }

      final response = await apiClient.dio.post(
        '/api/candidates/certificates',
        data: FormData.fromMap(formDataMap),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data;
        return CertificateModel.fromJson(data['data'] ?? data);
      }
      throw ServerException('Tạo chứng chỉ thất bại');
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) throw const AuthenticationException('Phiên đăng nhập hết hạn');
      throw ServerException(e.message ?? 'Lỗi kết nối server');
    } catch (e) {
      if (e is ServerException || e is AuthenticationException) rethrow;
      throw ServerException('Lỗi: ${e.toString()}');
    }
  }

  @override
  Future<CertificateModel> updateCertificate({
    required int id,
    required String name,
    Uint8List? imageBytes,
    String? fileName,
  }) async {
    try {
      final formDataMap = <String, dynamic>{
        'name': name,
      };

      if (imageBytes != null && fileName != null) {
        formDataMap['image'] = MultipartFile.fromBytes(
          imageBytes,
          filename: fileName,
        );
      }

      final response = await apiClient.dio.put(
        '/api/candidates/certificates/$id',
        data: FormData.fromMap(formDataMap),
      );

      if (response.statusCode == 200) {
        final data = response.data;
        return CertificateModel.fromJson(data['data'] ?? data);
      }
      throw ServerException('Cập nhật chứng chỉ thất bại');
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) throw const AuthenticationException('Phiên đăng nhập hết hạn');
      throw ServerException(e.message ?? 'Lỗi kết nối server');
    } catch (e) {
      if (e is ServerException || e is AuthenticationException) rethrow;
      throw ServerException('Lỗi: ${e.toString()}');
    }
  }


  @override
  Future<void> deleteCertificate(int id) async {
    try {
      final response = await apiClient.dio.delete('/api/candidates/certificates/$id');
      if (response.statusCode != 200 && response.statusCode != 204) {
        throw ServerException('Xóa chứng chỉ thất bại');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) throw const AuthenticationException('Phiên đăng nhập hết hạn');
      throw ServerException(e.message ?? 'Lỗi kết nối server');
    } catch (e) {
      if (e is ServerException || e is AuthenticationException) rethrow;
      throw ServerException('Lỗi: ${e.toString()}');
    }
  }

  // ─── Projects ────────────────────────────────────────────────────────

  @override
  Future<List<ProjectModel>> getProjects() async {
    try {
      final response = await apiClient.dio.get('/api/candidates/projects');
      if (response.statusCode == 200) {
        final data = response.data;
        final list = (data['data'] ?? data) as List;
        return list
            .map((e) => ProjectModel.fromJson(e as Map<String, dynamic>))
            .toList();
      }
      throw ServerException('Không thể lấy danh sách dự án');
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) throw const AuthenticationException('Phiên đăng nhập hết hạn');
      throw ServerException(e.message ?? 'Lỗi kết nối server');
    } catch (e) {
      if (e is ServerException || e is AuthenticationException) rethrow;
      throw ServerException('Lỗi: ${e.toString()}');
    }
  }

  @override
  Future<ProjectModel> createProject(ProjectModel project) async {
    try {
      final response = await apiClient.dio.post(
        '/api/candidates/projects',
        data: project.toCreateDto(),
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data;
        return ProjectModel.fromJson(data['data'] ?? data);
      }
      throw ServerException('Tạo dự án thất bại');
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) throw const AuthenticationException('Phiên đăng nhập hết hạn');
      throw ServerException(e.message ?? 'Lỗi kết nối server');
    } catch (e) {
      if (e is ServerException || e is AuthenticationException) rethrow;
      throw ServerException('Lỗi: ${e.toString()}');
    }
  }

  @override
  Future<ProjectModel> updateProject(int id, ProjectModel project) async {
    try {
      final response = await apiClient.dio.put(
        '/api/candidates/projects/$id',
        data: project.toUpdateDto(),
      );
      if (response.statusCode == 200) {
        final data = response.data;
        return ProjectModel.fromJson(data['data'] ?? data);
      }
      throw ServerException('Cập nhật dự án thất bại');
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) throw const AuthenticationException('Phiên đăng nhập hết hạn');
      throw ServerException(e.message ?? 'Lỗi kết nối server');
    } catch (e) {
      if (e is ServerException || e is AuthenticationException) rethrow;
      throw ServerException('Lỗi: ${e.toString()}');
    }
  }

  @override
  Future<void> deleteProject(int id) async {
    try {
      final response = await apiClient.dio.delete('/api/candidates/projects/$id');
      if (response.statusCode != 200 && response.statusCode != 204) {
        throw ServerException('Xóa dự án thất bại');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) throw const AuthenticationException('Phiên đăng nhập hết hạn');
      throw ServerException(e.message ?? 'Lỗi kết nối server');
    } catch (e) {
      if (e is ServerException || e is AuthenticationException) rethrow;
      throw ServerException('Lỗi: ${e.toString()}');
    }
  }

  @override
  Future<List<JobTypeModel>> getJobTypes() async {
    try {
      final response = await apiClient.dio.get('/api/candidates/job-types');
      if (response.data != null && response.data is List) {
        return (response.data as List)
            .map((e) => JobTypeModel.fromJson(e as Map<String, dynamic>))
            .toList();
      }
      return [];
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) throw const AuthenticationException('Phiên đăng nhập hết hạn');
      throw ServerException(e.message ?? 'Lỗi kết nối server');
    } catch (e) {
      if (e is ServerException || e is AuthenticationException) rethrow;
      throw ServerException('Lỗi: ${e.toString()}');
    }
  }

  // ─── Job Categories ──────────────────────────────────────────────────

  @override
  Future<List<JobCategoryModel>> getJobCategoriesMetadata() async {
    try {
      final response = await apiClient.dio.get('/api/metadata/job-categories');
      if (response.statusCode == 200) {
        final data = response.data;
        List list;
        if (data is List) {
          list = data;
        } else if (data is Map && data['data'] is List) {
          list = data['data'];
        } else {
          list = [];
        }
        return list
            .map((e) => JobCategoryModel.fromJson(e as Map<String, dynamic>))
            .toList();
      }
      throw ServerException('Không thể lấy danh sách ngành nghề');
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) throw const AuthenticationException('Phiên đăng nhập hết hạn');
      throw ServerException(e.message ?? 'Lỗi kết nối server');
    } catch (e) {
      if (e is ServerException || e is AuthenticationException) rethrow;
      throw ServerException('Lỗi: ${e.toString()}');
    }
  }

  @override
  Future<List<CandidateJobCategoryModel>> getCandidateJobCategories() async {
    try {
      final response = await apiClient.dio.get('/api/candidates/job-categories');
      if (response.statusCode == 200) {
        final data = response.data;
        List list;
        if (data is List) {
          list = data;
        } else if (data is Map && data['data'] is List) {
          list = data['data'];
        } else {
          list = [];
        }
        return list
            .map((e) => CandidateJobCategoryModel.fromJson(e as Map<String, dynamic>))
            .toList();
      }
      throw ServerException('Không thể lấy ngành nghề ứng viên đã chọn');
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) throw const AuthenticationException('Phiên đăng nhập hết hạn');
      throw ServerException(e.message ?? 'Lỗi kết nối server');
    } catch (e) {
      if (e is ServerException || e is AuthenticationException) rethrow;
      throw ServerException('Lỗi: ${e.toString()}');
    }
  }

  @override
  Future<void> addCandidateJobCategories(List<int> categoryIds) async {
    try {
      final response = await apiClient.dio.post(
        '/api/candidates/job-categories',
        data: {'categoryIds': categoryIds},
      );
      if (response.statusCode != 200 && response.statusCode != 201) {
        throw ServerException('Thêm ngành nghề thất bại');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) throw const AuthenticationException('Phiên đăng nhập hết hạn');
      throw ServerException(e.message ?? 'Lỗi kết nối server');
    } catch (e) {
      if (e is ServerException || e is AuthenticationException) rethrow;
      throw ServerException('Lỗi: ${e.toString()}');
    }
  }

  @override
  Future<void> deleteCandidateJobCategory(int mappingId) async {
    try {
      final response = await apiClient.dio.delete('/api/candidates/job-categories/$mappingId');
      if (response.statusCode != 200 && response.statusCode != 204) {
        throw ServerException('Xóa ngành nghề thất bại');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) throw const AuthenticationException('Phiên đăng nhập hết hạn');
      throw ServerException(e.message ?? 'Lỗi kết nối server');
    } catch (e) {
      if (e is ServerException || e is AuthenticationException) rethrow;
      throw ServerException('Lỗi: ${e.toString()}');
    }
  }

  // ─── Skills ───────────────────────────────────────────────────────────

  @override
  Future<List<SkillModel>> searchSkills(String query) async {
    try {
      final response = await apiClient.dio.get(
        '/api/metadata/skills/search',
        queryParameters: {'q': query, 'limit': 20},
      );
      if (response.statusCode == 200) {
        final data = response.data;
        List list;
        if (data is List) {
          list = data;
        } else if (data is Map && data['data'] is List) {
          list = data['data'];
        } else {
          list = [];
        }
        return list.map((e) => SkillModel.fromJson(e as Map<String, dynamic>)).toList();
      }
      throw ServerException('Không thể tìm kiếm kỹ năng');
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) throw const AuthenticationException('Phiên đăng nhập hết hạn');
      throw ServerException(e.message ?? 'Lỗi kết nối server');
    } catch (e) {
      if (e is ServerException || e is AuthenticationException) rethrow;
      throw ServerException('Lỗi: ${e.toString()}');
    }
  }

  @override
  Future<List<CandidateSkillModel>> getCandidateSkills() async {
    try {
      final response = await apiClient.dio.get('/api/candidates/skills');
      if (response.statusCode == 200) {
        final data = response.data;
        List list;
        if (data is List) {
          list = data;
        } else if (data is Map && data['data'] is List) {
          list = data['data'];
        } else {
          list = [];
        }
        return list.map((e) => CandidateSkillModel.fromJson(e as Map<String, dynamic>)).toList();
      }
      throw ServerException('Không thể lấy danh sách kỹ năng');
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) throw const AuthenticationException('Phiên đăng nhập hết hạn');
      throw ServerException(e.message ?? 'Lỗi kết nối server');
    } catch (e) {
      if (e is ServerException || e is AuthenticationException) rethrow;
      throw ServerException('Lỗi: ${e.toString()}');
    }
  }

  @override
  Future<void> addCandidateSkills(List<dynamic> skills) async {
    try {
      final response = await apiClient.dio.post(
        '/api/candidates/skills',
        data: {'skills': skills},
      );
      if (response.statusCode != 200 && response.statusCode != 201) {
        throw ServerException('Thêm kỹ năng thất bại');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) throw const AuthenticationException('Phiên đăng nhập hết hạn');
      throw ServerException(e.message ?? 'Lỗi kết nối server');
    } catch (e) {
      if (e is ServerException || e is AuthenticationException) rethrow;
      throw ServerException('Lỗi: ${e.toString()}');
    }
  }

  @override
  Future<void> deleteCandidateSkill(int mappingId) async {
    try {
      final response = await apiClient.dio.delete('/api/candidates/skills/$mappingId');
      if (response.statusCode != 200 && response.statusCode != 204) {
        throw ServerException('Xóa kỹ năng thất bại');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) throw const AuthenticationException('Phiên đăng nhập hết hạn');
      throw ServerException(e.message ?? 'Lỗi kết nối server');
    } catch (e) {
      if (e is ServerException || e is AuthenticationException) rethrow;
      throw ServerException('Lỗi: ${e.toString()}');
    }
  }

  @override
  Future<String?> uploadAvatar(Uint8List bytes, String fileName) async {
    try {
      final formData = FormData.fromMap({
        'file': MultipartFile.fromBytes(bytes, filename: fileName),
      });

      final response = await apiClient.dio.post(
        '/api/candidates/avatar',
        data: formData,
      );

      print('Avatar Upload Response: ${response.data}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data;
        // Trả về url để cập nhật local state, ưu tiên các trường common
        final String? url = data['url'] ?? data['data']?['url'] ?? data['avatarUrl'] ?? data['data']?['avatarUrl'];
        return url;
      }
      throw ServerException('Upload avatar thất bại');
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) throw const AuthenticationException('Phiên đăng nhập hết hạn');
      throw ServerException(e.message ?? 'Lỗi kết nối server');
    } catch (e) {
      if (e is ServerException || e is AuthenticationException) rethrow;
      throw ServerException('Lỗi: ${e.toString()}');
    }
  }

  @override
  Future<void> updateVisibility(bool isVisible) async {
    try {
      final response = await apiClient.dio.put(
        '/api/candidates/profile/visibility',
        data: {'isPublic': isVisible},
      );
      if (response.statusCode != 200 && response.statusCode != 201) {
        throw ServerException('Cập nhật trạng thái hiển thị thất bại');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw const AuthenticationException('Phiên đăng nhập hết hạn');
      }
      throw ServerException(e.message ?? 'Lỗi kết nối server');
    } catch (e) {
      if (e is ServerException || e is AuthenticationException) rethrow;
      throw ServerException('Đã xảy ra lỗi: ${e.toString()}');
    }
  }

  @override
  Future<void> parseCv() async {
    try {
      final response = await apiClient.dio.post(
        '/api/candidates/cv/parse',
        options: Options(
          receiveTimeout: const Duration(seconds: 120),
        ),
      );
      if (response.statusCode != 200 && response.statusCode != 201) {
        throw ServerException('Phân tích CV thất bại');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) throw const AuthenticationException('Phiên đăng nhập hết hạn');
      
      final data = e.response?.data;
      final String? serverMsg = data is Map ? (data['message'] ?? data['error'])?.toString() : null;

      if (e.response?.statusCode == 503 || e.response?.statusCode == 504) {
        throw ServerException(serverMsg ?? 'Dịch vụ AI đang quá tải, vui lòng thử lại sau vài phút');
      }
      
      if (e.response?.statusCode == 400) {
        throw ServerException(serverMsg ?? 'Chưa upload CV hoặc file không đọc được');
      }
      throw ServerException(serverMsg ?? e.message ?? 'Lỗi kết nối server');
    } catch (e) {
      if (e is ServerException || e is AuthenticationException) rethrow;
      throw ServerException('Đã xảy ra lỗi: ${e.toString()}');
    }
  }
}
