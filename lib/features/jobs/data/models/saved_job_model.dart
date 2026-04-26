import 'job_post_model.dart';
import '../../domain/entities/saved_job_entity.dart';

/// Model cho SavedJob với fromJson/toJson
class SavedJobModel extends SavedJobEntity {
  const SavedJobModel({
    required super.savedJobId,
    required super.candidateId,
    required super.jobPostId,
    required super.createdAt,
    super.job,
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
    // Handle nested job if present
    JobPostModel? nestedJob;
    if (json['job'] != null) {
      nestedJob = JobPostModel.fromJson(json['job'] as Map<String, dynamic>);
    }

    return SavedJobModel(
      savedJobId: _asInt(json['saved_job_id'] ?? json['id']),
      candidateId: _asInt(json['candidate_id'] ?? json['candidateId']),
      jobPostId: _asInt(json['job_post_id'] ?? json['jobId']),
      createdAt: DateTime.parse((json['created_at'] ?? json['savedAt'] ?? json['createdAt']) as String),
      job: nestedJob,
      jobTitle: json['job_title'] as String? ?? nestedJob?.title,
      companyName: json['company_name'] as String? ?? nestedJob?.companyName,
      companyLogo: json['company_logo'] as String? ?? nestedJob?.companyLogo,
      cityName: json['city_name'] as String? ?? nestedJob?.cityName,
      salaryMin: _asInt(json['salary_min'] ?? nestedJob?.salaryMin),
      salaryMax: _asInt(json['salary_max'] ?? nestedJob?.salaryMax),
      salaryType: json['salary_type'] as String? ?? nestedJob?.salaryType,
      jobType: json['job_type'] as String? ?? nestedJob?.jobType,
      jobLevel: json['job_level'] as String? ?? nestedJob?.levelName,
      deadline: (json['deadline'] != null)
          ? DateTime.parse(json['deadline'] as String)
          : nestedJob?.deadline,
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

  /// Chuyển SavedJobModel thành JSON
  Map<String, dynamic> toJson() {
    return {
      'saved_job_id': savedJobId,
      'candidate_id': candidateId,
      'job_post_id': jobPostId,
      'created_at': createdAt.toIso8601String(),
      'job': job != null ? (job as JobPostModel).toJson() : null,
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
