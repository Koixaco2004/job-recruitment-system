import '../../domain/entities/company_entity.dart';

class CompanyModel extends CompanyEntity {
  const CompanyModel({
    required super.id,
    required super.userCreatorId,
    required super.categoryId,
    required super.name,
    super.emailContact,
    super.phoneContact,
    super.address,
    super.provinceId,
    super.logoUrl,
    super.bannerUrl,
    super.description,
    super.content,
    super.companySize,
    super.websiteUrl,
    super.facebookUrl,
    super.linkedinUrl,
    super.businessLicenseUrl,
    required super.isVerified,
    super.verifiedAt,
    required super.createdAt,
    required super.updatedAt,
  });

  factory CompanyModel.fromJson(Map<String, dynamic> json) {
    return CompanyModel(
      id: json['id'] as int,
      userCreatorId: json['userCreatorId'] as int,
      categoryId: json['categoryId'] as int,
      name: json['name'] as String,
      emailContact: json['emailContact'] as String?,
      phoneContact: json['phoneContact'] as String?,
      address: json['address'] as String?,
      provinceId: json['provinceId'] as int?,
      logoUrl: json['logoUrl'] as String?,
      bannerUrl: json['bannerUrl'] as String?,
      description: json['description'] as String?,
      content: json['content'] as String?,
      companySize: json['companySize'] as String?,
      websiteUrl: json['websiteUrl'] as String?,
      facebookUrl: json['facebookUrl'] as String?,
      linkedinUrl: json['linkedinUrl'] as String?,
      businessLicenseUrl: json['businessLicenseUrl'] as String?,
      isVerified: json['isVerified'] as bool? ?? false,
      verifiedAt: json['verifiedAt'] != null
          ? DateTime.parse(json['verifiedAt'] as String)
          : null,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userCreatorId': userCreatorId,
      'categoryId': categoryId,
      'name': name,
      'emailContact': emailContact,
      'phoneContact': phoneContact,
      'address': address,
      'provinceId': provinceId,
      'logoUrl': logoUrl,
      'bannerUrl': bannerUrl,
      'description': description,
      'content': content,
      'companySize': companySize,
      'websiteUrl': websiteUrl,
      'facebookUrl': facebookUrl,
      'linkedinUrl': linkedinUrl,
      'businessLicenseUrl': businessLicenseUrl,
      'isVerified': isVerified,
      'verifiedAt': verifiedAt?.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}
