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
    final isWorking = json['isWorkingHere'] ??
        json['is_working_here'] ??
        json['is_current_job'] ??
        false;
    return WorkExperienceModel(
      id: json['id'] as int?,
      companyName: (json['companyName'] ?? json['company_name'] ?? '') as String,
      position: (json['position'] ?? '') as String,
      startDate: json['startDate'] != null || json['start_date'] != null
          ? DateTime.parse(
              (json['startDate'] ?? json['start_date']) as String)
          : DateTime.now(),
      endDate: (json['endDate'] ?? json['end_date']) != null
          ? DateTime.parse(
              (json['endDate'] ?? json['end_date']) as String)
          : null,
      description: (json['description'] as String?),
      isCurrentJob: isWorking is bool ? isWorking : isWorking == 1,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'companyName': companyName,
      'position': position,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate?.toIso8601String(),
      'description': description,
      'isWorkingHere': isCurrentJob,
    };
  }

  Map<String, dynamic> toCreateDto() {
    final dto = <String, dynamic>{
      'companyName': companyName,
      'position': position,
      'startDate': '${startDate.year}-${startDate.month.toString().padLeft(2, '0')}-${startDate.day.toString().padLeft(2, '0')}',
      'isWorkingHere': isCurrentJob ?? false,
    };
    if (endDate != null && !(isCurrentJob ?? false)) {
      dto['endDate'] = '${endDate!.year}-${endDate!.month.toString().padLeft(2, '0')}-${endDate!.day.toString().padLeft(2, '0')}';
    }
    if (description != null && description!.isNotEmpty) {
      dto['description'] = description;
    }
    return dto;
  }

  Map<String, dynamic> toUpdateDto() => toCreateDto();

  static WorkExperienceModel fromEntity(WorkExperienceEntity entity) {
    return WorkExperienceModel(
      id: entity.id,
      companyName: entity.companyName,
      position: entity.position,
      startDate: entity.startDate,
      endDate: entity.endDate,
      description: entity.description,
      isCurrentJob: entity.isCurrentJob,
    );
  }
}
