import 'package:flutter/material.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/usecases/login_usecase.dart';
import '../../domain/usecases/register_usecase.dart';

/// Provider quản lý state cho Authentication
class AuthProvider extends ChangeNotifier {
  final LoginUseCase loginUseCase;
  final RegisterUseCase registerUseCase;

  AuthProvider({
    required this.loginUseCase,
    required this.registerUseCase,
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
  void logout() {
    _user = null;
    _errorMessage = null;
    notifyListeners();
  }

  /// Clear error message
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
