import '../../domain/entities/work_experience_entity.dart';

class WorkExperienceModel extends WorkExperienceEntity {
  const WorkExperienceModel({
    super.id,
    required super.companyName,
    required super.position,
    required super.startDate,
    super.endDate,
    super.description,
    super.isCurrentJob,
  });

  factory WorkExperienceModel.fromJson(Map<String, dynamic> json) {
    return WorkExperienceModel(
      id: json['id'] as int?,
      companyName: json['company_name'] as String,
      position: json['position'] as String,
      startDate: DateTime.parse(json['start_date'] as String),
      endDate: json['end_date'] != null
          ? DateTime.parse(json['end_date'] as String)
          : null,
      description: json['description'] as String?,
      isCurrentJob: json['is_current_job'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'company_name': companyName,
      'position': position,
      'start_date': startDate.toIso8601String(),
      'end_date': endDate?.toIso8601String(),
      'description': description,
      'is_current_job': isCurrentJob,
    };
  }
}
