import '../../domain/entities/job_post_entity.dart';

/// Model kế thừa từ Entity và thêm fromJson/toJson
class JobPostModel extends JobPostEntity {
  const JobPostModel({
    required super.jobPostId,
    required super.employerId,
    required super.title,
    required super.description,
    required super.requirements,
    required super.benefits,
    required super.jobType,
    super.salaryMin,
    super.salaryMax,
    required super.salaryType,
    required super.numberOfPositions,
    required super.experienceRequired,
    required super.deadline,
    required super.status,
    required super.isPriority,
    required super.viewCount,
    required super.applicationCount,
    required super.createdAt,
    required super.updatedAt,
    required super.companyName,
    super.companyLogo,
    required super.cityName,
    required super.industryName,
    super.provinceId,
    super.categoryId,
    super.jobTypeId,
    super.skills,
    super.rejectionReason,
  });

  /// Tạo JobPostModel từ JSON
  factory JobPostModel.fromJson(Map<String, dynamic> json) {
    return JobPostModel(
      jobPostId: _asInt(json['job_post_id'] ?? json['id'] ?? json['jobPostId']),
      employerId: _asInt(json['employer_id'] ?? json['employerId']),
      title: json['title'] as String? ?? 'Không có tiêu đề',
      description: json['description'] as String? ?? '',
      requirements: json['requirements'] as String? ?? '',
      benefits: json['benefits'] as String? ?? '',
      jobType: _asString(json['job_type'] ?? (json['jobType'] is Map ? json['jobType']['name'] : json['jobType'])) ?? 'fulltime',
      salaryMin: _asInt(json['salary_min'] ?? json['salaryMin']),
      salaryMax: _asInt(json['salary_max'] ?? json['salaryMax']),
      salaryType: _asString(json['salary_type'] ?? json['currency']) ?? 'VND',
      numberOfPositions: _asInt(json['number_of_positions'] ?? json['slots']),
      experienceRequired: _asInt(json['experience_required'] ?? json['yearsOfExperience']),
      deadline: json['deadline'] != null 
          ? DateTime.parse(json['deadline'] as String)
          : DateTime.now(),
      status: _asString(json['status']) ?? 'pending',
      isPriority: json['is_priority'] == true || json['isPriority'] == true,
      viewCount: _asInt(json['view_count'] ?? json['viewCount']),
      applicationCount: _asInt(json['application_count'] ?? json['applicationCount']),
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at'] as String)
          : (json['createdAt'] != null ? DateTime.parse(json['createdAt'] as String) : DateTime.now()),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : (json['updatedAt'] != null ? DateTime.parse(json['updatedAt'] as String) : DateTime.now()),
      companyName: _asString(json['company_name'] ?? json['companyName'] ?? (json['company'] is Map ? (json['company'] as Map)['name'] : null)) ?? 'Không rõ công ty',
      companyLogo: _asString(json['company_logo'] ?? json['companyLogo'] ?? (json['company'] is Map ? (json['company'] as Map)['logoUrl'] : null)),
      cityName: _asString(json['city_name'] ?? json['cityName'] ?? (json['province'] is Map ? (json['province'] as Map)['name'] : null)) ?? 'Không rõ địa điểm',
      industryName: _asString(json['industry_name'] ?? json['industryName'] ?? (json['category'] is Map ? (json['category'] as Map)['name'] : null)) ?? 'Chưa xác định',
      provinceId: _asInt(json['province_id'] ?? json['provinceId'] ?? (json['province'] is Map ? (json['province'] as Map)['id'] : null)),
      categoryId: _asInt(json['category_id'] ?? json['categoryId'] ?? (json['category'] is Map ? (json['category'] as Map)['id'] : null)),
      jobTypeId: _asInt(json['job_type_id'] ?? json['jobTypeId'] ?? (json['jobType'] is Map ? (json['jobType'] as Map)['id'] : null)),
      skills: json['skills'] as List?,
      rejectionReason: _asString(json['rejection_reason'] ?? json['rejectionReason'] ?? json['reason']),
    );
  }

  static int _asInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is String) {
      return double.tryParse(value)?.toInt() ?? 0;
    }
    if (value is double) return value.toInt();
    return 0;
  }

  static String? _asString(dynamic value) {
    if (value == null) return null;
    if (value is String) return value;
    return value.toString();
  }

  /// Chuyển JobPostModel thành JSON
  Map<String, dynamic> toJson() {
    return {
      'job_post_id': jobPostId,
      'employer_id': employerId,
      'title': title,
      'description': description,
      'requirements': requirements,
      'benefits': benefits,
      'job_type': jobType,
      'salary_min': salaryMin,
      'salary_max': salaryMax,
      'salary_type': salaryType,
      'number_of_positions': numberOfPositions,
      'experience_required': experienceRequired,
      'deadline': deadline.toIso8601String(),
      'status': status,
      'is_priority': isPriority,
      'view_count': viewCount,
      'application_count': applicationCount,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'company_name': companyName,
      'company_logo': companyLogo,
      'city_name': cityName,
      'industry_name': industryName,
      'province_id': provinceId,
      'category_id': categoryId,
      'job_type_id': jobTypeId,
      'skills': skills,
      'rejection_reason': rejectionReason,
    };
  }
}
