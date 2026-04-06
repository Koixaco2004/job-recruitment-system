import '../../domain/entities/application_status_history_entity.dart';

class ApplicationStatusHistoryModel extends ApplicationStatusHistoryEntity {
  const ApplicationStatusHistoryModel({
    required super.id,
    required super.applicationId,
    super.oldStatus,
    required super.newStatus,
    super.reason,
    super.changedById,
    required super.createdAt,
  });

  factory ApplicationStatusHistoryModel.fromJson(Map<String, dynamic> json) {
    return ApplicationStatusHistoryModel(
      id: _asInt(json['id']),
      applicationId: _asInt(json['applicationId']),
      oldStatus: json['oldStatus'] as String?,
      newStatus: json['newStatus'] as String? ?? 'applied',
      reason: json['reason'] as String?,
      changedById: _asInt(json['changedById']),
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now(),
    );
  }

  static int _asInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is String) return int.tryParse(value) ?? 0;
    if (value is double) return value.toInt();
    return 0;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'applicationId': applicationId,
      'oldStatus': oldStatus,
      'newStatus': newStatus,
      'reason': reason,
      'changedById': changedById,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
