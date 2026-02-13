import 'package:equatable/equatable.dart';

/// Base class cho tất cả các Failure
abstract class Failure extends Equatable {
  final String message;

  const Failure(this.message);

  @override
  List<Object> get props => [message];
}

/// Lỗi từ server/API
class ServerFailure extends Failure {
  const ServerFailure(super.message);
}

/// Lỗi từ cache/local storage
class CacheFailure extends Failure {
  const CacheFailure(super.message);
}

/// Lỗi xác thực (sai email/password)
class AuthenticationFailure extends Failure {
  const AuthenticationFailure(super.message);
}

/// Lỗi network (không có internet)
class NetworkFailure extends Failure {
  const NetworkFailure(super.message);
}
