import '../../domain/entities/application_entity.dart';

/// Model cho Application với fromJson/toJson
class ApplicationModel extends ApplicationEntity {
  const ApplicationModel({
    super.applicationId,
    required super.jobPostId,
    required super.candidateId,
    super.cvFileUrl,
    super.coverLetter,
    required super.status,
    required super.appliedAt,
    super.viewedAt,
    super.updatedAt,
    super.jobTitle,
    super.companyName,
  });

  /// Tạo ApplicationModel từ JSON
  factory ApplicationModel.fromJson(Map<String, dynamic> json) {
    return ApplicationModel(
      applicationId: json['application_id'] as int?,
      jobPostId: json['job_post_id'] as int,
      candidateId: json['candidate_id'] as int,
      cvFileUrl: json['cv_file_url'] as String?,
      coverLetter: json['cover_letter'] as String?,
      status: json['status'] as String,
      appliedAt: DateTime.parse(json['applied_at'] as String),
      viewedAt: json['viewed_at'] != null
          ? DateTime.parse(json['viewed_at'] as String)
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
      jobTitle: json['job_title'] as String?,
      companyName: json['company_name'] as String?,
    );
  }

  /// Chuyển ApplicationModel thành JSON
  Map<String, dynamic> toJson() {
    return {
      'application_id': applicationId,
      'job_post_id': jobPostId,
      'candidate_id': candidateId,
      'cv_file_url': cvFileUrl,
      'cover_letter': coverLetter,
      'status': status,
      'applied_at': appliedAt.toIso8601String(),
      'viewed_at': viewedAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'job_title': jobTitle,
      'company_name': companyName,
    };
  }
}
