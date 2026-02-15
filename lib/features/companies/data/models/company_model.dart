import '../../domain/entities/company_entity.dart';

/// Model cho Company với JSON serialization
class CompanyModel extends CompanyEntity {
  const CompanyModel({
    required super.employerId,
    required super.companyName,
    super.logoUrl,
    super.coverImageUrl,
    super.industryName,
    super.companySize,
    super.website,
    super.description,
    super.address,
    super.cityName,
    super.benefits,
    super.foundedYear,
    super.jobCount,
  });

  factory CompanyModel.fromJson(Map<String, dynamic> json) {
    return CompanyModel(
      employerId: json['employer_id'] as int,
      companyName: json['company_name'] as String,
      logoUrl: json['logo_url'] as String?,
      coverImageUrl: json['cover_image_url'] as String?,
      industryName: json['industry_name'] as String?,
      companySize: json['company_size'] as String?,
      website: json['website'] as String?,
      description: json['description'] as String?,
      address: json['address'] as String?,
      cityName: json['city_name'] as String?,
      benefits: json['benefits'] as String?,
      foundedYear: json['founded_year'] as int?,
      jobCount: json['job_count'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'employer_id': employerId,
      'company_name': companyName,
      'logo_url': logoUrl,
      'cover_image_url': coverImageUrl,
      'industry_name': industryName,
      'company_size': companySize,
      'website': website,
      'description': description,
      'address': address,
      'city_name': cityName,
      'benefits': benefits,
      'founded_year': foundedYear,
      'job_count': jobCount,
    };
  }
}
