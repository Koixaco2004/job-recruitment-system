import '../../../../core/network/api_client.dart';
import '../../../../core/error/exceptions.dart';
import '../models/province_model.dart';
import '../models/job_category_model.dart';
import '../models/job_level_model.dart';
import '../models/skill_model.dart';
import 'package:dio/dio.dart';

abstract class MetadataRemoteDataSource {
  Future<List<ProvinceModel>> getProvinces();
  Future<List<JobCategoryModel>> getJobCategories();
  Future<List<JobLevelModel>> getJobLevels();
  Future<List<SkillModel>> searchSkills(String query, {int limit = 10});
}

class MetadataRemoteDataSourceImpl implements MetadataRemoteDataSource {
  final ApiClient apiClient;

  MetadataRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<List<ProvinceModel>> getProvinces() async {
    try {
      final response = await apiClient.dio.get('/api/metadata/provinces');
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.map((json) => ProvinceModel.fromJson(json)).toList();
      } else {
        throw ServerException('Failed to fetch provinces');
      }
    } on DioException catch (e) {
      throw ServerException(e.message ?? 'Lỗi kết nối khi tải tỉnh thành');
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<List<JobCategoryModel>> getJobCategories() async {
    try {
      final response = await apiClient.dio.get('/api/metadata/job-categories');
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.map((json) => JobCategoryModel.fromJson(json)).toList();
      } else {
        throw ServerException('Failed to fetch job categories');
      }
    } on DioException catch (e) {
      throw ServerException(e.message ?? 'Lỗi kết nối khi tải ngành nghề');
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<List<JobLevelModel>> getJobLevels() async {
    try {
      final response = await apiClient.dio.get('/api/metadata/job-levels');
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.map((json) => JobLevelModel.fromJson(json)).toList();
      } else {
        throw ServerException('Failed to fetch job levels');
      }
    } on DioException catch (e) {
      throw ServerException(e.message ?? 'Lỗi kết nối khi tải cấp bậc');
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<List<SkillModel>> searchSkills(String query, {int limit = 10}) async {
    try {
      final response = await apiClient.dio.get(
        '/api/metadata/skills/search',
        queryParameters: {'q': query, 'limit': limit},
      );
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.map((json) => SkillModel.fromJson(json)).toList();
      } else {
        throw ServerException('Failed to search skills');
      }
    } on DioException catch (e) {
      throw ServerException(e.message ?? 'Lỗi kết nối khi tìm kiếm kỹ năng');
    } catch (e) {
      throw ServerException(e.toString());
    }
  }
}
