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
}
