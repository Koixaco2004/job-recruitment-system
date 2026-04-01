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
    required super.jobLevel,
    super.salaryMin,
    super.salaryMax,
    required super.salaryType,
    required super.numberOfPositions,
    required super.experienceRequired,
    super.educationRequired,
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
      jobType: json['job_type'] as String? ?? json['jobType'] as String? ?? 'fulltime',
      jobLevel: json['job_level'] as String? ?? json['jobLevel'] as String? ?? 'junior',
      salaryMin: _asInt(json['salary_min'] ?? json['salaryMin']),
      salaryMax: _asInt(json['salary_max'] ?? json['salaryMax']),
      salaryType: json['salary_type'] as String? ?? json['currency'] as String? ?? 'VND',
      numberOfPositions: _asInt(json['number_of_positions'] ?? json['slots']),
      experienceRequired: _asInt(json['experience_required'] ?? json['yearsOfExperience']),
      educationRequired: json['education_required'] as String? ?? json['education'] as String?,
      deadline: json['deadline'] != null 
          ? DateTime.parse(json['deadline'] as String)
          : DateTime.now(),
      status: json['status'] as String? ?? 'pending',
      isPriority: json['is_priority'] == true || json['isPriority'] == true,
      viewCount: _asInt(json['view_count'] ?? json['viewCount']),
      applicationCount: _asInt(json['application_count'] ?? json['applicationCount']),
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : DateTime.now(),
      companyName: json['company_name'] as String? ?? json['companyName'] as String? ?? 'Không rõ công ty',
      companyLogo: json['company_logo'] as String? ?? json['companyLogo'] as String?,
      cityName: json['city_name'] as String? ?? json['cityName'] as String? ?? 'Không rõ địa điểm',
      industryName: json['industry_name'] as String? ?? json['industryName'] as String? ?? 'Chưa xác định',
      provinceId: _asInt(json['province_id'] ?? json['provinceId']),
      categoryId: _asInt(json['category_id'] ?? json['categoryId']),
      jobTypeId: _asInt(json['job_type_id'] ?? json['jobTypeId']),
    );
  }

  static int _asInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is String) return int.tryParse(value) ?? 0;
    if (value is double) return value.toInt();
    return 0;
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
      'job_level': jobLevel,
      'salary_min': salaryMin,
      'salary_max': salaryMax,
      'salary_type': salaryType,
      'number_of_positions': numberOfPositions,
      'experience_required': experienceRequired,
      'education_required': educationRequired,
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
    };
  }
}
