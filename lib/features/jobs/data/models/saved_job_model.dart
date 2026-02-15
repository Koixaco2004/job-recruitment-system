import '../../domain/entities/saved_job_entity.dart';

/// Model cho SavedJob với fromJson/toJson
class SavedJobModel extends SavedJobEntity {
  const SavedJobModel({
    required super.savedJobId,
    required super.candidateId,
    required super.jobPostId,
    required super.createdAt,
    super.jobTitle,
    super.companyName,
    super.companyLogo,
    super.cityName,
    super.salaryMin,
    super.salaryMax,
    super.salaryType,
    super.jobType,
    super.jobLevel,
    super.deadline,
  });

  /// Tạo SavedJobModel từ JSON
  factory SavedJobModel.fromJson(Map<String, dynamic> json) {
    return SavedJobModel(
      savedJobId: json['saved_job_id'] as int,
      candidateId: json['candidate_id'] as int,
      jobPostId: json['job_post_id'] as int,
      createdAt: DateTime.parse(json['created_at'] as String),
      jobTitle: json['job_title'] as String?,
      companyName: json['company_name'] as String?,
      companyLogo: json['company_logo'] as String?,
      cityName: json['city_name'] as String?,
      salaryMin: json['salary_min'] as int?,
      salaryMax: json['salary_max'] as int?,
      salaryType: json['salary_type'] as String?,
      jobType: json['job_type'] as String?,
      jobLevel: json['job_level'] as String?,
      deadline: json['deadline'] != null
          ? DateTime.parse(json['deadline'] as String)
          : null,
    );
  }

  /// Chuyển SavedJobModel thành JSON
  Map<String, dynamic> toJson() {
    return {
      'saved_job_id': savedJobId,
      'candidate_id': candidateId,
      'job_post_id': jobPostId,
      'created_at': createdAt.toIso8601String(),
      'job_title': jobTitle,
      'company_name': companyName,
      'company_logo': companyLogo,
      'city_name': cityName,
      'salary_min': salaryMin,
      'salary_max': salaryMax,
      'salary_type': salaryType,
      'job_type': jobType,
      'job_level': jobLevel,
      'deadline': deadline?.toIso8601String(),
    };
  }
}
