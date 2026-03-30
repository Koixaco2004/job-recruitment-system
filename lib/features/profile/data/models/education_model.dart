import '../../domain/entities/education_entity.dart';

class EducationModel extends EducationEntity {
  const EducationModel({
    super.id,
    required super.institution,
    required super.degree,
    required super.fieldOfStudy,
    required super.startDate,
    super.endDate,
    super.description,
    this.isStillStudying = false,
  });

  final bool isStillStudying;

  factory EducationModel.fromJson(Map<String, dynamic> json) {
    int? _asIntNullable(dynamic value) {
      if (value == null) return null;
      if (value is int) return value;
      if (value is num) return value.toInt();
      if (value is String) return int.tryParse(value);
      return null;
    }
    final isStill = json['isStillStudying'] ?? json['is_still_studying'] ?? false;
    return EducationModel(
      id: _asIntNullable(json['id']),
      // API uses 'schoolName', entity uses 'institution'
      institution: (json['schoolName'] ?? json['school_name'] ?? json['institution'] ?? '') as String,
      degree: (json['degree'] ?? '') as String,
      // API uses 'major', entity uses 'fieldOfStudy'
      fieldOfStudy: (json['major'] ?? json['field_of_study'] ?? json['fieldOfStudy'] ?? '') as String,
      startDate: (json['startDate'] ?? json['start_date']) != null
          ? DateTime.parse((json['startDate'] ?? json['start_date']) as String)
          : DateTime.now(),
      endDate: (json['endDate'] ?? json['end_date']) != null
          ? DateTime.parse((json['endDate'] ?? json['end_date']) as String)
          : null,
      description: json['description'] as String?,
      isStillStudying: isStill is bool ? isStill : isStill == 1,
    );
  }

  Map<String, dynamic> toCreateDto() {
    final dto = <String, dynamic>{
      'schoolName': institution,
      'degree': degree,
      'major': fieldOfStudy,
      'isStillStudying': isStillStudying,
    };
    if (startDate != null) {
      dto['startDate'] =
          '${startDate.year}-${startDate.month.toString().padLeft(2, '0')}-${startDate.day.toString().padLeft(2, '0')}';
    }
    if (endDate != null && !isStillStudying) {
      dto['endDate'] =
          '${endDate!.year}-${endDate!.month.toString().padLeft(2, '0')}-${endDate!.day.toString().padLeft(2, '0')}';
    }
    if (description != null && description!.isNotEmpty) {
      dto['description'] = description;
    }
    return dto;
  }

  Map<String, dynamic> toUpdateDto() => toCreateDto();

  static EducationModel fromEntity(EducationEntity entity, {bool isStillStudying = false}) {
    return EducationModel(
      id: entity.id,
      institution: entity.institution,
      degree: entity.degree,
      fieldOfStudy: entity.fieldOfStudy,
      startDate: entity.startDate,
      endDate: entity.endDate,
      description: entity.description,
      isStillStudying: isStillStudying,
    );
  }
}
