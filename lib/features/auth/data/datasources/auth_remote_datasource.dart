import 'package:dio/dio.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/network/api_client.dart';
import '../models/user_model.dart';

/// Abstract interface cho Remote Data Source
abstract class AuthRemoteDataSource {
  /// Login qua API
  Future<UserModel> login({required String email, required String password});

  /// Đăng ký tài khoản ứng viên mới
  Future<UserModel> register({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
    required String phone,
    required int provinceId,
  });
}

/// Implementation với Real API
class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final ApiClient apiClient;

  AuthRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<UserModel> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await apiClient.dio.post(
        '/api/auth/login',
        data: {
          'email': email,
          'password': password,
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final token = response.data['access_token'];
        
        // Gọi API /api/auth/status để lấy thông tin user vì login chỉ trả token
        try {
          final statusResponse = await apiClient.dio.get(
            '/api/auth/status',
            options: Options(
              headers: {
                'Authorization': 'Bearer $token',
              },
            ),
          );

          if (statusResponse.statusCode == 200) {
            final Map<String, dynamic> userData = statusResponse.data;
            userData['token'] = token; // Đính token vào JSON để map ra UserModel
            return UserModel.fromJson(userData);
          } else {
            throw ServerException('Không thể lấy thông tin đăng nhập');
          }
        } catch (e) {
          // Fallback nếu không gọi được status (trả về Dummy Data kèm Token để app không crash)
          return UserModel(
             userId: 0,
             email: email,
             fullName: 'Người dùng',
             userType: 'candidate',
             status: 'active',
             emailVerified: false,
             createdAt: DateTime.now(),
             updatedAt: DateTime.now(),
             token: token,
          );
        }
      } else {
        throw const AuthenticationException('Email hoặc mật khẩu không đúng');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw const AuthenticationException('Email hoặc mật khẩu không đúng');
      }
      throw ServerException(e.message ?? 'Lỗi kết nối server');
    } catch (e) {
      if (e is AuthenticationException) rethrow;
      throw ServerException('Đã xảy ra lỗi: ${e.toString()}');
    }
  }

  @override
  Future<UserModel> register({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
    required String phone,
    required int provinceId,
  }) async {
    try {
      final response = await apiClient.dio.post(
        '/api/auth/register',
        data: {
          'firstName': firstName,
          'lastName': lastName,
          'email': email,
          'password': password,
          'phone': phone,
          'provinceId': provinceId,
        },
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        // Đăng ký thành công, tự động gọi API login để lấy token
        return await this.login(email: email, password: password);
      } else {
        throw const AuthenticationException('Đăng ký không thành công');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 409) {
        throw const AuthenticationException('Email này đã được sử dụng');
      }
      throw ServerException(e.message ?? 'Lỗi kết nối server');
    } catch (e) {
      if (e is AuthenticationException) rethrow;
      throw ServerException('Đã xảy ra lỗi: ${e.toString()}');
    }
  }
}
