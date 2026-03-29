import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

class RegisterEmployerUseCase {
  final AuthRepository repository;

  RegisterEmployerUseCase({required this.repository});

  Future<Either<Failure, UserEntity>> call({
    required String email,
    required String password,
  }) async {
    return await repository.employerRegister(
      email: email,
      password: password,
    );
  }
}
