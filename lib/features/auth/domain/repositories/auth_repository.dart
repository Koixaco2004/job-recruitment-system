import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/user_entity.dart';

/// Abstract repository cho Authentication
/// Domain layer chỉ định nghĩa interface, không quan tâm implementation
abstract class AuthRepository {
  /// Login với email và password
  /// Trả về Either<Failure, UserEntity>
  Future<Either<Failure, UserEntity>> login({
    required String email,
    required String password,
  });

  /// Đăng ký tài khoản ứng viên mới
  Future<Either<Failure, UserEntity>> register({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
    required String phone,
    required int provinceId,
  });

  /// Đăng ký tài khoản Nhà tuyển dụng mới
  Future<Either<Failure, UserEntity>> employerRegister({
    required String email,
    required String password,
  });

  /// Logout
  Future<Either<Failure, void>> logout();

  /// Lấy user hiện tại từ cache
  Future<Either<Failure, UserEntity>> getCurrentUser();

  /// Kiểm tra user đã đăng nhập chưa
  Future<bool> isLoggedIn();
}
