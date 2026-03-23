import 'package:dio/dio.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/network/api_client.dart';
import '../models/candidate_profile_model.dart';

/// Abstract interface cho Profile Data Source
abstract class ProfileRemoteDataSource {
  Future<CandidateProfileModel> getProfile();
  Future<CandidateProfileModel> updateProfile(CandidateProfileModel profile);
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
}
