import '../../domain/entities/company_entity.dart';

/// Model cho Company với JSON serialization
class CompanyModel extends CompanyEntity {
  const CompanyModel({
    required super.employerId,
    required super.companyName,
    super.userCreatorId,
    super.categoryId,
    super.emailContact,
    super.phoneContact,
    super.address,
    super.provinceId,
    super.cityName,
    super.logoUrl,
    super.coverImageUrl,
    super.industryName,
    super.companySize,
    super.website,
    super.facebookUrl,
    super.linkedinUrl,
    super.description,
    super.content,
    super.benefits,
    super.foundedYear,
    super.jobCount,
    super.isVerified,
    super.images,
  });

  factory CompanyModel.fromJson(Map<String, dynamic> json) {
    int _asInt(dynamic value) {
      if (value == null) return 0;
      if (value is int) return value;
      if (value is num) return value.toInt();
      if (value is String) return int.tryParse(value) ?? 0;
      return 0;
    }

    return CompanyModel(
      employerId: _asInt(json['id'] ?? json['employer_id'] ?? json['employerId']),
      companyName: (json['name'] ?? json['company_name'] ?? json['companyName'] ?? '') as String,
      userCreatorId: _asInt(json['userCreatorId']),
      categoryId: _asInt(json['categoryId']),
      emailContact: json['emailContact'] as String?,
      phoneContact: json['phoneContact'] as String?,
      address: json['address'] as String?,
      provinceId: _asInt(json['provinceId']),
      cityName: json['cityName'] as String?,
      logoUrl: json['logoUrl'] ?? json['logo_url'] as String?,
      coverImageUrl: json['bannerUrl'] ?? json['banner_url'] ?? json['cover_image_url'] as String?,
      industryName: json['industryName'] as String?,
      companySize: json['companySize'] ?? json['company_size'] as String?,
      website: json['websiteUrl'] ?? json['website_url'] ?? json['website'] as String?,
      facebookUrl: json['facebookUrl'] as String?,
      linkedinUrl: json['linkedinUrl'] as String?,
      description: json['description'] as String?,
      content: json['content'] as String?,
      benefits: json['benefits'] as String?,
      foundedYear: _asInt(json['founded_year'] ?? json['foundedYear']),
      jobCount: _asInt(json['job_count'] ?? json['jobCount']),
      isVerified: json['isVerified'] ?? false,
      images: json['images'] != null 
          ? (json['images'] as List).map((e) {
              if (e is String) return e;
              if (e is Map && e.containsKey('imageUrl')) return e['imageUrl'] as String;
              return '';
            }).where((url) => url.isNotEmpty).toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': employerId,
      'name': companyName,
      'userCreatorId': userCreatorId,
      'categoryId': categoryId,
      'emailContact': emailContact,
      'phoneContact': phoneContact,
      'address': address,
      'provinceId': provinceId,
      'logoUrl': logoUrl,
      'bannerUrl': coverImageUrl,
      'companySize': companySize,
      'websiteUrl': website,
      'facebookUrl': facebookUrl,
      'linkedinUrl': linkedinUrl,
      'description': description,
      'content': content,
      'isVerified': isVerified,
    };
  }
}
