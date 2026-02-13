import 'package:equatable/equatable.dart';

/// Entity đại diện cho User (dựa trên bảng USERS)
class UserEntity extends Equatable {
  final int userId;
  final String email;
  final String? phone;
  final String fullName;
  final String? avatarUrl;
  final String userType; // 'candidate', 'employer', 'admin'
  final String status; // 'active', 'locked', 'pending'
  final bool emailVerified;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? lastLogin;

  const UserEntity({
    required this.userId,
    required this.email,
    this.phone,
    required this.fullName,
    this.avatarUrl,
    required this.userType,
    required this.status,
    required this.emailVerified,
    required this.createdAt,
    required this.updatedAt,
    this.lastLogin,
  });

  @override
  List<Object?> get props => [
    userId,
    email,
    phone,
    fullName,
    avatarUrl,
    userType,
    status,
    emailVerified,
    createdAt,
    updatedAt,
    lastLogin,
  ];
}
