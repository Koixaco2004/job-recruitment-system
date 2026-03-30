import 'dart:typed_data';
import 'package:dio/dio.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/network/api_client.dart';
import '../models/company_model.dart';
import '../../../jobs/data/models/job_post_model.dart';

/// Interface cho Company Remote Data Source
abstract class CompanyRemoteDataSource {
  Future<List<CompanyModel>> getCompanies();
  Future<CompanyModel> getCompanyById(int employerId);
  Future<List<CompanyModel>> searchCompanies(String query);
  Future<List<JobPostModel>> getCompanyJobs(int employerId);
  
  // Employer - Company Profile Management
  Future<CompanyModel> updateCompanyProfile({
    required String name,
    String? description,
    String? content,
    String? websiteUrl,
    String? address,
    int? provinceId,
    int? categoryId,
    String? emailContact,
    String? phoneContact,
    String? companySize,
    String? facebookUrl,
    String? linkedinUrl,
  });
  Future<String> uploadLogo(Uint8List bytes, String fileName);
  Future<String> uploadBanner(Uint8List bytes, String fileName);
  Future<String> uploadGalleryImage(Uint8List bytes, String fileName);
}

/// Real implementation using ApiClient
class CompanyRemoteDataSourceImpl implements CompanyRemoteDataSource {
  final ApiClient apiClient;

  CompanyRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<List<CompanyModel>> getCompanies() async {
    try {
      final response = await apiClient.dio.get('/api/companies');
      if (response.statusCode == 200) {
        final List data = response.data['data'] ?? response.data;
        return data.map((e) => CompanyModel.fromJson(e)).toList();
      }
      throw ServerException('Không thể lấy danh sách công ty');
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<CompanyModel> getCompanyById(int employerId) async {
    try {
      final response = await apiClient.dio.get('/api/companies/$employerId');
      if (response.statusCode == 200) {
        final data = response.data['data'] ?? response.data;
        return CompanyModel.fromJson(data);
      }
      throw ServerException('Không tìm thấy công ty');
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<List<CompanyModel>> searchCompanies(String query) async {
    try {
      final response = await apiClient.dio.get('/api/companies/search', queryParameters: {'q': query});
      if (response.statusCode == 200) {
        final List data = response.data['data'] ?? response.data;
        return data.map((e) => CompanyModel.fromJson(e)).toList();
      }
      return [];
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<List<JobPostModel>> getCompanyJobs(int employerId) async {
    try {
      final response = await apiClient.dio.get('/api/companies/$employerId/jobs');
      if (response.statusCode == 200) {
        final List data = response.data['data'] ?? response.data;
        return data.map((e) => JobPostModel.fromJson(e)).toList();
      }
      return [];
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<CompanyModel> updateCompanyProfile({
    required String name,
    String? description,
    String? content,
    String? websiteUrl,
    String? address,
    int? provinceId,
    int? categoryId,
    String? emailContact,
    String? phoneContact,
    String? companySize,
    String? facebookUrl,
    String? linkedinUrl,
  }) async {
    try {
      final response = await apiClient.dio.put(
        '/api/companies/profile',
        data: {
          'name': name,
          'description': description,
          'content': content,
          'websiteUrl': websiteUrl,
          'address': address,
          'provinceId': provinceId,
          'categoryId': categoryId,
          'emailContact': emailContact,
          'phoneContact': phoneContact,
          'companySize': companySize,
          'facebookUrl': facebookUrl,
          'linkedinUrl': linkedinUrl,
        },
      );
      if (response.statusCode == 200) {
        final data = response.data['data'] ?? response.data;
        return CompanyModel.fromJson(data);
      }
      throw ServerException('Cập nhật thông hồ sơ công ty thất bại');
    } on DioException catch (e) {
      final message = e.response?.data?['message'];
      if (message is List) {
        throw ServerException(message.join(', '));
      } else if (message is String) {
        throw ServerException(message);
      }
      throw ServerException(e.toString());
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<String> uploadLogo(Uint8List bytes, String fileName) async {
    return _uploadFile('/api/companies/logo', bytes, fileName, 'file');
  }

  @override
  Future<String> uploadBanner(Uint8List bytes, String fileName) async {
    return _uploadFile('/api/companies/banner', bytes, fileName, 'file');
  }

  @override
  Future<String> uploadGalleryImage(Uint8List bytes, String fileName) async {
    // Backend expects 'files' array for gallery
    return _uploadFile('/api/companies/images', bytes, fileName, 'files', isArray: true);
  }

  Future<String> _uploadFile(String url, Uint8List bytes, String fileName, String fieldName, {bool isArray = false}) async {
    try {
      final file = MultipartFile.fromBytes(bytes, filename: fileName);
      final formData = FormData.fromMap({
        fieldName: isArray ? [file] : file,
      });
      final response = await apiClient.dio.post(url, data: formData);
      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data;
        // Handle different possible response structures
        final resultUrl = data['url'] ?? data['logoUrl'] ?? data['bannerUrl'] ?? '';
        if (resultUrl.isEmpty && data['data'] != null) {
          final nestedData = data['data'];
          if (nestedData is Map) {
            return nestedData['url'] ?? nestedData['imageUrl'] ?? '';
          }
          if (nestedData is List && nestedData.isNotEmpty) {
            return nestedData[0]['imageUrl'] ?? nestedData[0]['url'] ?? '';
          }
        }
        return resultUrl;
      }
      throw ServerException('Upload files thất bại');
    } on DioException catch (e) {
      throw ServerException(e.response?.data?['message']?.toString() ?? e.toString());
    } catch (e) {
      throw ServerException(e.toString());
    }
  }
}
