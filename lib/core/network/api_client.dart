import 'dart:io';
import 'package:dio/dio.dart';
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
        ),
      ) {
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
        onError: (DioException e, handler) {
          // Xử lý lỗi chung ở đây nếu cần (VD: 401 thì logout)
          return handler.next(e);
        },
      ),
    );
  }
}
