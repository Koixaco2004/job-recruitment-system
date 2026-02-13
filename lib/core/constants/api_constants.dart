class ApiConstants {
  // Base URL - sẽ thay đổi khi có API thật
  static const String baseUrl = 'https://api.recruitment-app.com';

  // Auth endpoints
  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String logout = '/auth/logout';
  static const String refreshToken = '/auth/refresh-token';

  // Storage keys
  static const String tokenKey = 'auth_token';
  static const String userKey = 'user_data';
}
