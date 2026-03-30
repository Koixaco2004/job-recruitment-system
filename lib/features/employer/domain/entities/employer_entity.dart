import 'package:equatable/equatable.dart';
import '../../../auth/domain/entities/user_entity.dart';
import 'company_entity.dart';

class EmployerEntity extends Equatable {
  final int id;
  final int userId;
  final int? companyId;
  final String fullName;
  final String phoneContact;
  final String? avatarUrl;
  final bool isAdminCompany;
  final String status;
  final DateTime createdAt;
  final DateTime updatedAt;
  final UserEntity? user;
  final CompanyEntity? company;

  const EmployerEntity({
    required this.id,
    required this.userId,
    this.companyId,
    required this.fullName,
    required this.phoneContact,
    this.avatarUrl,
    required this.isAdminCompany,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    this.user,
    this.company,
  });

  @override
  List<Object?> get props => [
        id,
        userId,
        companyId,
        fullName,
        phoneContact,
        avatarUrl,
        isAdminCompany,
        status,
        createdAt,
        updatedAt,
        user,
        company,
      ];
}
