import '../../domain/entities/job_category_entity.dart';

class JobCategoryModel extends JobCategoryEntity {
  const JobCategoryModel({
    required super.id,
    required super.name,
    required super.slug,
  });

  factory JobCategoryModel.fromJson(Map<String, dynamic> json) {
    int _asInt(dynamic value) {
      if (value == null) return 0;
      if (value is int) return value;
      if (value is num) return value.toInt();
      if (value is String) return int.tryParse(value) ?? 0;
      return 0;
    }
    return JobCategoryModel(
      id: _asInt(json['id']),
      name: (json['name'] ?? '') as String,
      slug: (json['slug'] ?? '') as String,
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
