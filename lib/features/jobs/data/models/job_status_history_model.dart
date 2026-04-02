import '../../domain/entities/job_status_history_entity.dart';

/// Model xử lý JSON cho lịch sử thay đổi trạng thái
class JobStatusHistoryModel extends JobStatusHistoryEntity {
  const JobStatusHistoryModel({
    required super.id,
    required super.jobPostId,
    required super.oldStatus,
    required super.newStatus,
    super.reason,
    super.changedById,
    required super.createdAt,
  });

  factory JobStatusHistoryModel.fromJson(Map<String, dynamic> json) {
    return JobStatusHistoryModel(
      id: json['id'] as int? ?? 0,
      jobPostId: json['jobId'] as int? ?? json['job_post_id'] as int? ?? 0,
      oldStatus: json['oldStatus'] as String? ?? json['old_status'] as String? ?? '',
      newStatus: json['newStatus'] as String? ?? json['new_status'] as String? ?? '',
      reason: json['reason'] as String? ?? json['rejection_reason'] as String?,
      changedById: json['changedById'] as int? ?? json['changed_by_id'] as int?,
      createdAt: json['createdAt'] != null 
          ? DateTime.parse(json['createdAt'] as String)
          : (json['created_at'] != null ? DateTime.parse(json['created_at'] as String) : DateTime.now()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'jobId': jobPostId,
      'oldStatus': oldStatus,
      'newStatus': newStatus,
      'reason': reason,
      'changedById': changedById,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
