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
    super.images,
    super.employers,
  });

  factory CompanyModel.fromJson(Map<String, dynamic> json) {
    // Helper to safely parse integers from various types (int, double, string, or null)
    int? _asInt(dynamic value) {
      if (value == null) return null;
      if (value is int) return value;
      if (value is double) return value.toInt();
      if (value is String) return int.tryParse(value);
      return null;
    }

    return CompanyModel(
      id: _asInt(json['id']) ?? 0,
      userCreatorId: _asInt(json['userCreatorId']) ?? 0,
      categoryId: _asInt(json['categoryId']) ?? 0,
      name: json['name'] as String? ?? 'Chưa có tên',
      emailContact: json['emailContact'] as String?,
      phoneContact: json['phoneContact'] as String?,
      address: json['address'] as String?,
      provinceId: _asInt(json['provinceId']),
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
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt'] as String) : DateTime.now(),
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt'] as String) : DateTime.now(),
      images: json['images'] != null 
          ? (json['images'] as List).map((e) {
              if (e is String) return e;
              if (e is Map) {
                return (e['image_url'] ?? e['imageUrl'] ?? '') as String;
              }
              return '';
            }).where((url) => url.isNotEmpty).toList()
          : null,
      employers: json['employers'] != null ? List<String>.from(json['employers'] as List) : null,
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
      'images': images,
      'employers': employers,
    };
  }
}
