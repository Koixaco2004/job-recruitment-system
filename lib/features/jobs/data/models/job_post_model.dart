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
    super.address,
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
  });

  /// Tạo JobPostModel từ JSON
  factory JobPostModel.fromJson(Map<String, dynamic> json) {
    return JobPostModel(
      jobPostId: json['job_post_id'] as int,
      employerId: json['employer_id'] as int,
      title: json['title'] as String,
      description: json['description'] as String,
      requirements: json['requirements'] as String,
      benefits: json['benefits'] as String,
      jobType: json['job_type'] as String,
      jobLevel: json['job_level'] as String,
      salaryMin: json['salary_min'] as int?,
      salaryMax: json['salary_max'] as int?,
      salaryType: json['salary_type'] as String,
      numberOfPositions: json['number_of_positions'] as int,
      experienceRequired: json['experience_required'] as int,
      educationRequired: json['education_required'] as String?,
      address: json['address'] as String?,
      deadline: DateTime.parse(json['deadline'] as String),
      status: json['status'] as String,
      isPriority: json['is_priority'] as bool,
      viewCount: json['view_count'] as int,
      applicationCount: json['application_count'] as int,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      companyName: json['company_name'] as String,
      companyLogo: json['company_logo'] as String?,
      cityName: json['city_name'] as String,
      industryName: json['industry_name'] as String,
    );
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
      'address': address,
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
    };
  }
}
