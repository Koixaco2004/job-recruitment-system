import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/error/exceptions.dart';
import '../models/user_model.dart';

/// Abstract interface cho Local Data Source
abstract class AuthLocalDataSource {
  /// Lưu token vào secure storage
  Future<void> cacheToken(String token);

  /// Lấy token từ secure storage
  Future<String?> getToken();

  /// Lưu user data vào secure storage
  Future<void> cacheUser(UserModel user);

  /// Lấy user data từ secure storage
  Future<UserModel> getCachedUser();

  /// Xóa tất cả dữ liệu (logout)
  Future<void> clearCache();
}

/// Implementation sử dụng flutter_secure_storage
class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  final FlutterSecureStorage secureStorage;

  AuthLocalDataSourceImpl({required this.secureStorage});

  @override
  Future<void> cacheToken(String token) async {
    await secureStorage.write(key: ApiConstants.tokenKey, value: token);
  }

  @override
  Future<String?> getToken() async {
    return await secureStorage.read(key: ApiConstants.tokenKey);
  }

  @override
  Future<void> cacheUser(UserModel user) async {
    final userJson = jsonEncode(user.toJson());
    await secureStorage.write(key: ApiConstants.userKey, value: userJson);
  }

  @override
  Future<UserModel> getCachedUser() async {
    final userJson = await secureStorage.read(key: ApiConstants.userKey);
    if (userJson != null) {
      return UserModel.fromJson(jsonDecode(userJson));
    } else {
      throw const CacheException('Không tìm thấy dữ liệu user');
    }
  }

  @override
  Future<void> clearCache() async {
    await secureStorage.delete(key: ApiConstants.tokenKey);
    await secureStorage.delete(key: ApiConstants.userKey);
  }
}
