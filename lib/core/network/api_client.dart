import 'dart:io';
import 'package:dio/dio.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:cookie_jar/cookie_jar.dart';
import '../../features/auth/data/datasources/auth_local_datasource.dart';

class ApiClient {
  final Dio dio;
  final AuthLocalDataSource authLocalDataSource;

  ApiClient({required this.authLocalDataSource})
    : dio = Dio(
        BaseOptions(
          baseUrl: Platform.isAndroid
              ? "http://10.0.2.2:3000"
              : "http://localhost:3000",
          connectTimeout: const Duration(seconds: 10),
          receiveTimeout: const Duration(seconds: 10),
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
          // QUAN TRỌNG: Backend NestJS yêu cầu gửi kèm Credentials cho HttpOnly Cookie
          extra: {'withCredentials': true},
        ),
      ) {
    // Thêm CookieManager để quản lý HttpOnly Cookie (Refresh Token)
    dio.interceptors.add(CookieManager(CookieJar()));
    
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          // Thêm token vào header nếu chưa có
          final token = await authLocalDataSource.getToken();
          if (token != null && token.isNotEmpty && !options.headers.containsKey('Authorization')) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
        onError: (DioException e, handler) async {
          // Xử lý lỗi 401: Thử Refresh Token
          if (e.response?.statusCode == 401) {
            try {
              // Gọi API refresh (CookieManager sẽ tự gửi refresh_token trong Cookie)
              final refreshResponse = await dio.post('/api/auth/refresh');
              
              if (refreshResponse.statusCode == 200 || refreshResponse.statusCode == 201) {
                final newAccessToken = refreshResponse.data['access_token'];
                
                // Lưu token mới vào local storage
                await authLocalDataSource.cacheToken(newAccessToken);
                
                // Cập nhật header cho request hiện tại và thử lại
                e.requestOptions.headers['Authorization'] = 'Bearer $newAccessToken';
                
                final response = await dio.fetch(e.requestOptions);
                return handler.resolve(response);
              }
            } catch (refreshError) {
              // Nếu refresh thất bại (Refresh Token hết hạn), xóa cache và yêu cầu đăng nhập lại
              await authLocalDataSource.clearCache();
            }
          }
          return handler.next(e);
        },
      ),
    );
  }
}
