import 'dart:typed_data';
import 'package:dio/dio.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/network/api_client.dart';
import '../models/candidate_profile_model.dart';
import '../models/work_experience_model.dart';
import '../models/education_model.dart';
import '../models/certificate_model.dart';

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
}
