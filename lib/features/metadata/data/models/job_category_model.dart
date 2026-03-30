import '../../domain/entities/job_category_entity.dart';

class JobCategoryModel extends JobCategoryEntity {
  const JobCategoryModel({
    required super.id,
    required super.name,
    required super.slug,
  });

  factory JobCategoryModel.fromJson(Map<String, dynamic> json) {
    return JobCategoryModel(
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
