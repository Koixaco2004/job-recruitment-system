/// Exception khi gọi API thất bại
class ServerException implements Exception {
  final String message;
  const ServerException(this.message);

  @override
  String toString() => message;
}

/// Exception khi cache thất bại
class CacheException implements Exception {
  final String message;
  const CacheException(this.message);

  @override
  String toString() => message;
}

/// Exception khi xác thực thất bại
class AuthenticationException implements Exception {
  final String message;
  const AuthenticationException(this.message);

  @override
  String toString() => message;
}
