import '../../domain/entities/project_entity.dart';

class ProjectModel extends ProjectEntity {
  const ProjectModel({
    super.id,
    required super.name,
    super.startDate,
    super.endDate,
    super.description,
  });

  factory ProjectModel.fromJson(Map<String, dynamic> json) {
    return ProjectModel(
      id: json['id'] as int?,
      name: (json['name'] ?? '') as String,
      startDate: json['startDate'] != null
          ? DateTime.parse(json['startDate'] as String)
          : null,
      endDate: json['endDate'] != null
          ? DateTime.parse(json['endDate'] as String)
          : null,
      description: json['description'] as String?,
    );
  }

  Map<String, dynamic> toCreateDto() {
    final dto = <String, dynamic>{
      'name': name,
    };
    if (startDate != null) {
      dto['startDate'] =
          '${startDate!.year}-${startDate!.month.toString().padLeft(2, '0')}-${startDate!.day.toString().padLeft(2, '0')}';
    }
    if (endDate != null) {
      dto['endDate'] =
          '${endDate!.year}-${endDate!.month.toString().padLeft(2, '0')}-${endDate!.day.toString().padLeft(2, '0')}';
    }
    if (description != null) {
      dto['description'] = description;
    }
    return dto;
  }

  Map<String, dynamic> toUpdateDto() => toCreateDto();

  static ProjectModel fromEntity(ProjectEntity entity) {
    return ProjectModel(
      id: entity.id,
      name: entity.name,
      startDate: entity.startDate,
      endDate: entity.endDate,
      description: entity.description,
    );
  }
}
