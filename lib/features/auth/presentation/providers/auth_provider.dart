import 'package:flutter/material.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/usecases/login_usecase.dart';
import '../../domain/usecases/register_usecase.dart';

import '../../domain/usecases/logout_usecase.dart';

/// Provider quản lý state cho Authentication
class AuthProvider extends ChangeNotifier {
  final LoginUseCase loginUseCase;
  final RegisterUseCase registerUseCase;
  final LogoutUseCase logoutUseCase;

  AuthProvider({
    required this.loginUseCase,
    required this.registerUseCase,
    required this.logoutUseCase,
  });

  // State
  bool _isLoading = false;
  UserEntity? _user;
  String? _errorMessage;

  // Getters
  bool get isLoading => _isLoading;
  UserEntity? get user => _user;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _user != null;

  /// Login method
  Future<bool> login({required String email, required String password}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final result = await loginUseCase(email: email, password: password);

    return result.fold(
      (failure) {
        // Login thất bại
        _isLoading = false;
        _errorMessage = failure.message;
        notifyListeners();
        return false;
      },
      (user) {
        // Login thành công
        _isLoading = false;
        _user = user;
        _errorMessage = null;
        notifyListeners();
        return true;
      },
    );
  }

  /// Register method
  Future<bool> register({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
    required String phone,
    required int provinceId,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final result = await registerUseCase(
      firstName: firstName,
      lastName: lastName,
      email: email,
      password: password,
      phone: phone,
      provinceId: provinceId,
    );

    return result.fold(
      (failure) {
        // Đăng ký thất bại
        _isLoading = false;
        _errorMessage = failure.message;
        notifyListeners();
        return false;
      },
      (user) {
        // Đăng ký thành công
        _isLoading = false;
        _user = user;
        _errorMessage = null;
        notifyListeners();
        return true;
      },
    );
  }

  /// Logout method
  Future<void> logout() async {
    _isLoading = true;
    notifyListeners();

    await logoutUseCase();

    _user = null;
    _errorMessage = null;
    _isLoading = false;
    notifyListeners();
  }

  /// Clear error message
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
