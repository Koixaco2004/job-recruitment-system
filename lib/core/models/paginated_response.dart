/// Lớp generic để xử lý dữ liệu phân trang từ API
class PaginatedResponse<T> {
  final List<T> data;
  final int total;
  final int page;
  final int lastPage;

  const PaginatedResponse({
    required this.data,
    required this.total,
    required this.page,
    required this.lastPage,
  });

  /// Factory để tạo PaginatedResponse từ JSON
  /// [fromJsonT] là hàm để chuyển đổi từng item trong mảng 'data' sang kiểu T
  factory PaginatedResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Object? json) fromJsonT,
  ) {
    return PaginatedResponse<T>(
      data: (json['data'] as List<dynamic>?)
              ?.map((item) => fromJsonT(item))
              .toList() ??
          [],
      total: _asInt(json['total']),
      page: _asInt(json['page']),
      lastPage: _asInt(json['lastPage'] ?? json['last_page']),
    );
  }

  /// Tạo một PaginatedResponse rỗng
  factory PaginatedResponse.empty() {
    return const PaginatedResponse(
      data: [],
      total: 0,
      page: 1,
      lastPage: 1,
    );
  }

  static int _asInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is String) return int.tryParse(value) ?? 0;
    if (value is double) return value.toInt();
    return 0;
  }
}
