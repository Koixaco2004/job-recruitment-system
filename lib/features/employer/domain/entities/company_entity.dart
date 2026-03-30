import 'package:equatable/equatable.dart';

class CompanyEntity extends Equatable {
  final int id;
  final int userCreatorId;
  final int categoryId;
  final String name;
  final String? emailContact;
  final String? phoneContact;
  final String? address;
  final int? provinceId;
  final String? logoUrl;
  final String? bannerUrl;
  final String? description;
  final String? content;
  final String? companySize;
  final String? websiteUrl;
  final String? facebookUrl;
  final String? linkedinUrl;
  final String? businessLicenseUrl;
  final bool isVerified;
  final DateTime? verifiedAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  const CompanyEntity({
    required this.id,
    required this.userCreatorId,
    required this.categoryId,
    required this.name,
    this.emailContact,
    this.phoneContact,
    this.address,
    this.provinceId,
    this.logoUrl,
    this.bannerUrl,
    this.description,
    this.content,
    this.companySize,
    this.websiteUrl,
    this.facebookUrl,
    this.linkedinUrl,
    this.businessLicenseUrl,
    required this.isVerified,
    this.verifiedAt,
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  List<Object?> get props => [
        id,
        userCreatorId,
        categoryId,
        name,
        emailContact,
        phoneContact,
        address,
        provinceId,
        logoUrl,
        bannerUrl,
        description,
        content,
        companySize,
        websiteUrl,
        facebookUrl,
        linkedinUrl,
        businessLicenseUrl,
        isVerified,
        verifiedAt,
        createdAt,
        updatedAt,
      ];
}
