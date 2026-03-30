import 'dart:typed_data';
import 'package:dio/dio.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/error/exceptions.dart';
import '../models/employer_model.dart';

abstract class EmployerRemoteDataSource {
  Future<EmployerModel> getProfile();
  Future<void> setupCompany({
    required String fullName,
    required String phoneContact,
    required String companyName,
    required int categoryId,
    int? provinceId,
    String? address,
  });
  Future<EmployerModel> updateProfile({
    required String fullName,
    required String phoneContact,
  });
  Future<String> uploadAvatar({
    required Uint8List imageBytes,
    required String fileName,
  });
}

class EmployerRemoteDataSourceImpl implements EmployerRemoteDataSource {
  final ApiClient apiClient;

  EmployerRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<EmployerModel> getProfile() async {
    try {
      final response = await apiClient.dio.get('/api/employers/profile');
      if (response.statusCode == 200) {
        return EmployerModel.fromJson(response.data);
      } else {
        throw ServerException('Không thể lấy thông tin nhà tuyển dụng');
      }
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<void> setupCompany({
    required String fullName,
    required String phoneContact,
    required String companyName,
    required int categoryId,
    int? provinceId,
    String? address,
  }) async {
    try {
      await apiClient.dio.post(
        '/api/employers/setup-company',
        data: {
          'fullName': fullName,
          'phoneContact': phoneContact,
          'companyName': companyName,
          'categoryId': categoryId,
          'provinceId': provinceId,
          'address': address,
        },
      );
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<EmployerModel> updateProfile({
    required String fullName,
    required String phoneContact,
  }) async {
    try {
      final response = await apiClient.dio.put(
        '/api/employers/profile',
        data: {
          'fullName': fullName,
          'phoneContact': phoneContact,
        },
      );
      if (response.statusCode == 200) {
        return EmployerModel.fromJson(response.data);
      } else {
        throw ServerException('Cập nhật thông tin thất bại');
      }
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<String> uploadAvatar({
    required Uint8List imageBytes,
    required String fileName,
  }) async {
    try {
      final formData = FormData.fromMap({
        'file': MultipartFile.fromBytes(
          imageBytes,
          filename: fileName,
        ),
      });

      final response = await apiClient.dio.post(
        '/api/employers/avatar',
        data: formData,
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        // API upload avatar usually returns the URL or we might need to get it from profile
        // Let's assume it returns { url: "..." } or similar based on typical candidate flow
        // If not, we'll suggest refreshing the profile.
        // Actually, many of our APIs wrap in 'data'
        final data = response.data;
        return data['url'] ?? data['avatarUrl'] ?? '';
      } else {
        throw ServerException('Upload ảnh đại diện thất bại');
      }
    } catch (e) {
      throw ServerException(e.toString());
    }
  }
}
