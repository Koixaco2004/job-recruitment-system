import '../../domain/entities/employer_entity.dart';
import '../../../auth/data/models/user_model.dart';
import 'company_model.dart';

class EmployerModel extends EmployerEntity {
  const EmployerModel({
    required super.id,
    required super.userId,
    super.companyId,
    required super.fullName,
    required super.phoneContact,
    super.avatarUrl,
    required super.isAdminCompany,
    required super.status,
    required super.createdAt,
    required super.updatedAt,
    super.user,
    super.company,
  });

  factory EmployerModel.fromJson(Map<String, dynamic> json) {
    // Helper to safely parse integers from various types (int, double, string, or null)
    int? _asInt(dynamic value) {
      if (value == null) return null;
      if (value is int) return value;
      if (value is double) return value.toInt();
      if (value is String) return int.tryParse(value);
      return null;
    }

    return EmployerModel(
      id: _asInt(json['id']) ?? 0,
      userId: _asInt(json['userId']) ?? 0,
      companyId: _asInt(json['companyId']),
      fullName: (json['fullName'] ?? '') as String,
      phoneContact: (json['phoneContact'] ?? '') as String,
      avatarUrl: json['avatarUrl'] as String?,
      isAdminCompany: json['isAdminCompany'] as bool? ?? false,
      status: (json['status'] ?? 'active') as String,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : DateTime.now(),
      user: json['user'] != null ? UserModel.fromJson(json['user']) : null,
      company: json['company'] != null
          ? CompanyModel.fromJson(json['company'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'companyId': companyId,
      'fullName': fullName,
      'phoneContact': phoneContact,
      'avatarUrl': avatarUrl,
      'isAdminCompany': isAdminCompany,
      'status': status,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}
