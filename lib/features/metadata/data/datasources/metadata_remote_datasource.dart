import '../../../../core/network/api_client.dart';
import '../../../../core/error/exceptions.dart';
import '../models/province_model.dart';
import 'package:dio/dio.dart';

abstract class MetadataRemoteDataSource {
  Future<List<ProvinceModel>> getProvinces();
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
}
