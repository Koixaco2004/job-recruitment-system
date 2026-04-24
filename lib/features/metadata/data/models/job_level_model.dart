import '../../domain/entities/job_level_entity.dart';

class JobLevelModel extends JobLevelEntity {
  const JobLevelModel({
    required super.id,
    required super.name,
    required super.slug,
  });

  factory JobLevelModel.fromJson(Map<String, dynamic> json) {
    return JobLevelModel(
      id: json['id'] as int,
      name: json['name'] as String,
      slug: json['slug'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'slug': slug,
    };
  }
}
