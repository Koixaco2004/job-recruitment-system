import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/user_entity.dart';

/// Abstract repository cho Authentication
/// Domain layer chỉ định nghĩa interface, không quan tâm implementation
abstract class AuthRepository {
  /// Login với email và password
  /// Trả về Either&lt;Failure, UserEntity&gt;
  Future<Either<Failure, UserEntity>> login({
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
