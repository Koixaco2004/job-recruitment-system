import 'package:flutter/material.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/usecases/login_usecase.dart';
import '../../domain/usecases/register_employer_usecase.dart';
import '../../domain/usecases/register_usecase.dart';

import '../../domain/usecases/logout_usecase.dart';
import '../../domain/usecases/verify_email_usecase.dart';
import '../../domain/usecases/resend_verification_usecase.dart';
import '../../domain/usecases/get_status_usecase.dart';
import '../../domain/usecases/forgot_password_usecase.dart';
import '../../domain/usecases/reset_password_usecase.dart';
import '../../domain/usecases/change_password_usecase.dart';

/// Provider quản lý state cho Authentication
class AuthProvider extends ChangeNotifier {
  final LoginUseCase loginUseCase;
  final RegisterUseCase registerUseCase;
  final RegisterEmployerUseCase registerEmployerUseCase;
  final LogoutUseCase logoutUseCase;
  final VerifyEmailUseCase verifyEmailUseCase;
  final ResendVerificationUseCase resendVerificationUseCase;
  final GetStatusUseCase getStatusUseCase;
  final ForgotPasswordUseCase forgotPasswordUseCase;
  final ResetPasswordUseCase resetPasswordUseCase;
  final ChangePasswordUseCase changePasswordUseCase;

  AuthProvider({
    required this.loginUseCase,
    required this.registerUseCase,
    required this.registerEmployerUseCase,
    required this.logoutUseCase,
    required this.verifyEmailUseCase,
    required this.resendVerificationUseCase,
    required this.getStatusUseCase,
    required this.forgotPasswordUseCase,
    required this.resetPasswordUseCase,
    required this.changePasswordUseCase,
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

    try {
      final result = await loginUseCase(email: email, password: password);

      return result.fold(
        (failure) {
          // Login thất bại
          _errorMessage = failure.message;
          return false;
        },
        (user) {
          // Login thành công
          _user = user;
          _errorMessage = null;
          return true;
        },
      );
    } finally {
      _isLoading = false;
      notifyListeners();
    }
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

    try {
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
          _errorMessage = failure.message;
          return false;
        },
        (user) {
          // Đăng ký thành công
          _user = user;
          _errorMessage = null;
          return true;
        },
      );
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Register Employer method
  Future<bool> employerRegister({
    required String email,
    required String password,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await registerEmployerUseCase(
        email: email,
        password: password,
      );

      return result.fold(
        (failure) {
          _errorMessage = failure.message;
          return false;
        },
        (user) {
          _user = user;
          _errorMessage = null;
          return true;
        },
      );
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Logout method
  Future<void> logout() async {
    _isLoading = true;
    notifyListeners();

    try {
      await logoutUseCase();
    } finally {
      _user = null;
      _errorMessage = null;
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Clear error message
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  /// Verify Email method
  Future<bool> verifyEmail(String token) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await verifyEmailUseCase.execute(token);

      return await result.fold(
        (failure) async {
          _errorMessage = failure.message;
          return false;
        },
        (_) async {
          // Xác thực thành công, refresh status để cập nhật emailVerified flag
          await refreshUserStatus();
          return true;
        },
      );
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Resend Verification Email method
  Future<bool> resendVerification() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await resendVerificationUseCase.execute();

      return result.fold(
        (failure) {
          _errorMessage = failure.message;
          return false;
        },
        (_) => true,
      );
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Refresh user status from server
  Future<bool> refreshUserStatus() async {
    final result = await getStatusUseCase.execute();
    return result.fold(
      (failure) {
        debugPrint('DEBUG: Failed to refresh user status: ${failure.message}');
        _errorMessage = failure.message;
        return false;
      },
      (user) {
        _user = user;
        notifyListeners();
        return true;
      },
    );
  }

  /// Forgot Password method
  Future<bool> forgotPassword(String email) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await forgotPasswordUseCase(email);

      return result.fold(
        (failure) {
          _errorMessage = failure.message;
          return false;
        },
        (_) => true,
      );
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Reset Password method
  Future<bool> resetPassword({
    required String email,
    required String token,
    required String newPassword,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await resetPasswordUseCase(
        email: email,
        token: token,
        newPassword: newPassword,
      );

      return result.fold(
        (failure) {
          _errorMessage = failure.message;
          return false;
        },
        (_) => true,
      );
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Change Password method (when logged in)
  Future<bool> changePassword({
    required String oldPassword,
    required String newPassword,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await changePasswordUseCase(
        oldPassword: oldPassword,
        newPassword: newPassword,
      );

      return result.fold(
        (failure) {
          _errorMessage = failure.message;
          return false;
        },
        (_) => true,
      );
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
