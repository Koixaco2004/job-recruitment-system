import '../../domain/entities/job_category_entity.dart';

class JobCategoryModel extends JobCategoryEntity {
  const JobCategoryModel({
    required super.id,
    required super.name,
  });

  factory JobCategoryModel.fromJson(Map<String, dynamic> json) {
    return JobCategoryModel(
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

class CandidateJobCategoryModel extends CandidateJobCategoryEntity {
  const CandidateJobCategoryModel({
    required super.id,
    required super.candidateId,
    required super.jobCategoryId,
    super.jobCategory,
  });

  factory CandidateJobCategoryModel.fromJson(Map<String, dynamic> json) {
    return CandidateJobCategoryModel(
      id: json['id'] as int? ?? 0,
      candidateId: json['candidateId'] as int? ?? 0,
      jobCategoryId: json['jobCategoryId'] as int? ?? (json['jobCategory'] != null ? (json['jobCategory']['id'] as int? ?? 0) : 0),
      jobCategory: json['jobCategory'] != null
          ? JobCategoryModel.fromJson(json['jobCategory'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'candidateId': candidateId,
      'jobCategoryId': jobCategoryId,
    };
  }
}
