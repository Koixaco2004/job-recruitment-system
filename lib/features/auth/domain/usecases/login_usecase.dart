import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

/// Use case cho Login
/// Mỗi use case đại diện cho một business action cụ thể
class LoginUseCase {
  final AuthRepository repository;

  LoginUseCase(this.repository);

  /// Execute login
  Future<Either<Failure, UserEntity>> call({
    required String email,
    required String password,
  }) async {
    // Có thể thêm validation logic ở đây
    if (email.isEmpty || password.isEmpty) {
      return const Left(
        AuthenticationFailure('Email và mật khẩu không được để trống'),
      );
    }

    return await repository.login(email: email, password: password);
  }
}
