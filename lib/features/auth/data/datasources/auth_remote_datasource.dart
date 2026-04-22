import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
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

  /// Đăng ký tài khoản Nhà tuyển dụng mới
  Future<UserModel> employerRegister({
    required String email,
    required String password,
  });

  /// Lấy trạng thái user hiện tại
  Future<UserModel> getStatus();

  /// Xác thực email qua token
  Future<void> verifyEmail({required String token});

  /// Gửi lại email xác thực
  Future<void> resendVerification();

  /// Quên mật khẩu - gửi email lấy OTP
  Future<void> forgotPassword({required String email});

  /// Đặt lại mật khẩu bằng OTP
  Future<void> resetPassword({
    required String email,
    required String token,
    required String newPassword,
  });

  /// Đổi mật khẩu (khi đã login)
  Future<void> changePassword({
    required String oldPassword,
    required String newPassword,
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
            debugPrint('DEBUG: /api/auth/status response: $userData');
            userData['token'] = token; // Đính token vào JSON để map ra UserModel
            return UserModel.fromJson(userData);
          } else {
            throw ServerException('Không thể lấy thông tin đăng nhập: Status Code ${statusResponse.statusCode}');
          }
        } catch (e) {
          debugPrint('DEBUG: Error during status check for token: $token');
          debugPrint('DEBUG: Error details: $e');
          if (e is ServerException || e is AuthenticationException) rethrow;
          throw ServerException('Lỗi khi lấy trạng thái tài khoản: $e');
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
      if (e is AuthenticationException || e is ServerException) rethrow;
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
      if (e is AuthenticationException || e is ServerException) rethrow;
      throw ServerException('Đã xảy ra lỗi: ${e.toString()}');
    }
  }

  @override
  Future<UserModel> employerRegister({
    required String email,
    required String password,
  }) async {
    try {
      final response = await apiClient.dio.post(
        '/api/auth/employer/register',
        data: {
          'email': email,
          'password': password,
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
      if (e is AuthenticationException || e is ServerException) rethrow;
      throw ServerException('Đã xảy ra lỗi: ${e.toString()}');
    }
  }

  @override
  Future<UserModel> getStatus() async {
    try {
      final response = await apiClient.dio.get('/api/auth/status');

      if (response.statusCode == 200) {
        final Map<String, dynamic> userData = response.data;
        // Lấy token cũ từ local storage vì API status không trả token
        final token = await apiClient.authLocalDataSource.getToken();
        userData['token'] = token ?? '';
        return UserModel.fromJson(userData);
      } else {
        throw ServerException('Không thể lấy thông tin trạng thái: ${response.statusCode}');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw const AuthenticationException('Chưa đăng nhập hoặc phiên làm việc hết hạn');
      }
      throw ServerException(e.message ?? 'Lỗi kết nối server');
    } catch (e) {
      if (e is AuthenticationException || e is ServerException) rethrow;
      throw ServerException('Đã xảy ra lỗi: ${e.toString()}');
    }
  }

  @override
  Future<void> verifyEmail({required String token}) async {
    try {
      final response = await apiClient.dio.get(
        '/api/auth/verify-email',
        queryParameters: {'token': token},
      );

      if (response.statusCode != 200) {
        throw ServerException('Xác thực email thất bại');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        throw ServerException('Mã xác thực không tồn tại hoặc đã hết hạn');
      }
      if (e.response?.statusCode == 400) {
        throw ServerException('Mã xác thực không hợp lệ');
      }
      throw ServerException(e.message ?? 'Lỗi kết nối server');
    } catch (e) {
      throw ServerException('Đã xảy ra lỗi: ${e.toString()}');
    }
  }

  @override
  Future<void> resendVerification() async {
    try {
      final response = await apiClient.dio.post(
        '/api/auth/resend-verification',
      );

      if (response.statusCode != 200 && response.statusCode != 201) {
        throw ServerException('Gửi lại email xác thực thất bại');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 400) {
        throw ServerException('Email này đã được xác thực rồi');
      }
      if (e.response?.statusCode == 401) {
        throw const AuthenticationException('Vui lòng đăng nhập để thực hiện hành động này');
      }
      throw ServerException(e.message ?? 'Lỗi kết nối server');
    } catch (e) {
      if (e is AuthenticationException) rethrow;
      throw ServerException('Đã xảy ra lỗi: ${e.toString()}');
    }
  }

  @override
  Future<void> forgotPassword({required String email}) async {
    try {
      final response = await apiClient.dio.post(
        '/api/auth/forgot-password',
        data: {'email': email},
      );

      if (response.statusCode != 200 && response.statusCode != 201) {
        throw ServerException('Gửi yêu cầu khôi phục mật khẩu thất bại');
      }
    } on DioException catch (e) {
      final message = e.response?.data?['message'];
      throw ServerException(message ?? e.message ?? 'Lỗi kết nối server');
    } catch (e) {
      throw ServerException('Đã xảy ra lỗi: ${e.toString()}');
    }
  }

  @override
  Future<void> resetPassword({
    required String email,
    required String token,
    required String newPassword,
  }) async {
    try {
      final response = await apiClient.dio.post(
        '/api/auth/reset-password',
        data: {
          'email': email,
          'token': token,
          'newPassword': newPassword,
        },
      );

      if (response.statusCode != 200 && response.statusCode != 201) {
        throw ServerException('Đặt lại mật khẩu thất bại');
      }
    } on DioException catch (e) {
      final message = e.response?.data?['message'];
      throw ServerException(message ?? e.message ?? 'Lỗi kết nối server');
    } catch (e) {
      throw ServerException('Đã xảy ra lỗi: ${e.toString()}');
    }
  }

  @override
  Future<void> changePassword({
    required String oldPassword,
    required String newPassword,
  }) async {
    try {
      final response = await apiClient.dio.patch(
        '/api/auth/change-password',
        data: {
          'oldPassword': oldPassword,
          'newPassword': newPassword,
        },
      );

      if (response.statusCode != 200 && response.statusCode != 204) {
        throw ServerException('Đổi mật khẩu thất bại');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw const AuthenticationException('Mật khẩu cũ không chính xác');
      }
      final message = e.response?.data?['message'];
      throw ServerException(message ?? e.message ?? 'Lỗi kết nối server');
    } catch (e) {
      if (e is AuthenticationException) rethrow;
      throw ServerException('Đã xảy ra lỗi: ${e.toString()}');
    }
  }
}
