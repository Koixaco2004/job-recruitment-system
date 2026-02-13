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
  });

  factory EducationModel.fromJson(Map<String, dynamic> json) {
    return EducationModel(
      id: json['id'] as int?,
      institution: json['institution'] as String,
      degree: json['degree'] as String,
      fieldOfStudy: json['field_of_study'] as String,
      startDate: DateTime.parse(json['start_date'] as String),
      endDate: json['end_date'] != null
          ? DateTime.parse(json['end_date'] as String)
          : null,
      description: json['description'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'institution': institution,
      'degree': degree,
      'field_of_study': fieldOfStudy,
      'start_date': startDate.toIso8601String(),
      'end_date': endDate?.toIso8601String(),
      'description': description,
    };
  }
}
