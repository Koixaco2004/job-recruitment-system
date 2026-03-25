import '../../domain/entities/job_type_entity.dart';

class JobTypeModel extends JobTypeEntity {
  const JobTypeModel({
    required super.id,
    required super.name,
  });

  factory JobTypeModel.fromJson(Map<String, dynamic> json) {
    return JobTypeModel(
      id: json['id'] as int,
      name: json['name'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
    };
  }
}
