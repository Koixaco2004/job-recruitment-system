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
    return UserModel(
      userId: json['user_id'] as int,
      email: json['email'] as String,
      phone: json['phone'] as String?,
      fullName: json['full_name'] as String,
      avatarUrl: json['avatar_url'] as String?,
      userType: json['user_type'] as String,
      status: json['status'] as String,
      emailVerified: json['email_verified'] as bool,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      lastLogin: json['last_login'] != null
          ? DateTime.parse(json['last_login'] as String)
          : null,
      token: json['token'] as String,
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
