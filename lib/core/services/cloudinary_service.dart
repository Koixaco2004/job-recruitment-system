import 'dart:typed_data';
import 'package:dio/dio.dart';

/// Service upload file lên Cloudinary (hỗ trợ cả Web và Mobile/Desktop)
class CloudinaryService {
  final Dio _dio;

  // Cloudinary config
  static const String _cloudName = 'dzgk9oo8u';
  static const String _uploadPreset = 'cv_upload';
  static const String _uploadUrl =
      'https://api.cloudinary.com/v1_1/$_cloudName/image/upload';

  CloudinaryService({Dio? dio}) : _dio = dio ?? Dio();

  /// Upload file bằng bytes (tương thích Web + Mobile/Desktop)
  Future<String> uploadFileBytes(Uint8List bytes, String fileName) async {
    final formData = FormData.fromMap({
      'file': MultipartFile.fromBytes(bytes, filename: fileName),
      'upload_preset': _uploadPreset,
      'resource_type': 'auto',
    });

    try {
      final response = await _dio.post(
        _uploadUrl,
        data: formData,
        options: Options(headers: {'Content-Type': 'multipart/form-data'}),
      );

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        final url = data['secure_url'] as String;
        return url;
      } else {
        throw Exception('Upload thất bại: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw Exception(
        'Lỗi kết nối khi upload: ${e.message ?? 'Unknown error'}',
      );
    }
  }
}
