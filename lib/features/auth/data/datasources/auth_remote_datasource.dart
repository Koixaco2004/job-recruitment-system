import '../../../../core/error/exceptions.dart';
import '../models/user_model.dart';

/// Abstract interface cho Remote Data Source
abstract class AuthRemoteDataSource {
  /// Login qua API
  Future<UserModel> login({required String email, required String password});

  /// Đăng ký tài khoản ứng viên mới
  Future<UserModel> register({
    required String fullName,
    required String email,
    required String password,
  });
}

/// Implementation với Mock Data
class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  @override
  Future<UserModel> login({
    required String email,
    required String password,
  }) async {
    // Giả lập delay 2 giây như gọi API thật
    await Future.delayed(const Duration(seconds: 2));

    // Mock data dựa trên email
    if (email == 'candidate@test.com') {
      return UserModel.fromJson({
        'user_id': 1,
        'email': 'candidate@test.com',
        'phone': '0123456789',
        'full_name': 'Nguyễn Văn A',
        'avatar_url': 'https://i.pravatar.cc/150?img=1',
        'user_type': 'candidate',
        'status': 'active',
        'email_verified': true,
        'created_at': '2024-01-01T00:00:00Z',
        'updated_at': '2024-01-01T00:00:00Z',
        'last_login': DateTime.now().toIso8601String(),
        'token': 'mock_jwt_token_candidate_12345',
      });
    } else if (email == 'employer@test.com') {
      return UserModel.fromJson({
        'user_id': 2,
        'email': 'employer@test.com',
        'phone': '0987654321',
        'full_name': 'Công ty ABC',
        'avatar_url': 'https://i.pravatar.cc/150?img=2',
        'user_type': 'employer',
        'status': 'active',
        'email_verified': true,
        'created_at': '2024-01-01T00:00:00Z',
        'updated_at': '2024-01-01T00:00:00Z',
        'last_login': DateTime.now().toIso8601String(),
        'token': 'mock_jwt_token_employer_67890',
      });
    } else {
      // Giả lập lỗi authentication
      throw const AuthenticationException('Email hoặc mật khẩu không đúng');
    }
  }

  @override
  Future<UserModel> register({
    required String fullName,
    required String email,
    required String password,
  }) async {
    // Giả lập delay 2 giây như gọi API thật
    await Future.delayed(const Duration(seconds: 2));

    // Giả lập check email trùng
    if (email == 'candidate@test.com' || email == 'employer@test.com') {
      throw const AuthenticationException('Email này đã được sử dụng');
    }

    // Trả về mock data cho user mới đăng ký thành công
    return UserModel.fromJson({
      'user_id': DateTime.now().millisecondsSinceEpoch % 10000, // Random ID
      'email': email,
      'phone': null,
      'full_name': fullName,
      'avatar_url': null,
      'user_type': 'candidate', // Luôn đăng ký ứng viên
      'status': 'active',
      'email_verified': false,
      'created_at': DateTime.now().toIso8601String(),
      'updated_at': DateTime.now().toIso8601String(),
      'last_login': DateTime.now().toIso8601String(),
      'token': 'mock_jwt_token_new_user_${DateTime.now().millisecondsSinceEpoch}',
    });
  }
}
