import '../../domain/entities/user_entity.dart';

/// Model kế thừa từ Entity và thêm fromJson/toJson
/// Bao gồm thêm trường token từ response API
class UserModel extends UserEntity {
  final String token; // JWT token từ server

  const UserModel({
    required super.userId,
    required super.email,
    super.phone,
    required super.fullName,
    super.avatarUrl,
    required super.userType,
    required super.status,
    required super.emailVerified,
    required super.createdAt,
    required super.updatedAt,
    super.lastLogin,
    required this.token,
  });

  /// Tạo UserModel từ JSON (response từ API)
  factory UserModel.fromJson(Map<String, dynamic> json) {
    // Helper to safely parse integers from various types (int, double, string, or null)
    int _asInt(dynamic value) {
      if (value == null) return 0;
      if (value is int) return value;
      if (value is double) return value.toInt();
      if (value is String) return int.tryParse(value) ?? 0;
      return 0;
    }

    // API backend thực tế thường thiết kế dạng camelCase (e.g. userId, fullName)
    // Nhưng data mock đang dùng snake_case nên ta phải fallback qua lại:
    return UserModel(
      userId: _asInt(json['user_id'] ?? json['id'] ?? json['userId']),
      email: json['email'] as String,
      phone: json['phone'] as String?,
      fullName: json['full_name'] ?? json['fullName'] ?? '${json['lastName'] ?? ''} ${json['firstName'] ?? ''}'.trim(),
      avatarUrl: json['avatar_url'] ?? json['avatarUrl'] as String?,
      userType: json['user_type'] ?? json['userType'] ?? json['role'] ?? 'candidate',
      status: json['status'] ?? 'active',
      emailVerified: json['email_verified'] ?? json['emailVerified'] ?? json['isEmailVerified'] ?? false,
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) 
               : json['createdAt'] != null ? DateTime.parse(json['createdAt']) 
               : DateTime.now(),
      updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at']) 
               : json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) 
               : DateTime.now(),
      lastLogin: json['last_login'] != null ? DateTime.parse(json['last_login']) 
               : json['lastLogin'] != null ? DateTime.parse(json['lastLogin']) 
               : null,
      token: json['token'] ?? json['access_token'] ?? '', // token có thể null nếu fetch status, ta tạo copyWith sau
    );
  }

  /// Chuyển UserModel thành JSON (để lưu vào cache)
  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'email': email,
      'phone': phone,
      'full_name': fullName,
      'avatar_url': avatarUrl,
      'user_type': userType,
      'status': status,
      'email_verified': emailVerified,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'last_login': lastLogin?.toIso8601String(),
      'token': token,
    };
  }

  /// Copy with method để tạo instance mới với một số field thay đổi
  UserModel copyWith({
    int? userId,
    String? email,
    String? phone,
    String? fullName,
    String? avatarUrl,
    String? userType,
    String? status,
    bool? emailVerified,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? lastLogin,
    String? token,
  }) {
    return UserModel(
      userId: userId ?? this.userId,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      fullName: fullName ?? this.fullName,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      userType: userType ?? this.userType,
      status: status ?? this.status,
      emailVerified: emailVerified ?? this.emailVerified,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      lastLogin: lastLogin ?? this.lastLogin,
      token: token ?? this.token,
    );
  }
}
