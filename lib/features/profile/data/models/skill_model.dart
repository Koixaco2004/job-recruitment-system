import '../../domain/entities/skill_entity.dart';

class SkillModel extends SkillEntity {
  const SkillModel({
    required super.id,
    required super.canonicalName,
    required super.slug,
    super.aliases,
    required super.type,
    super.useCount,
    required super.createdAt,
  });

  factory SkillModel.fromJson(Map<String, dynamic> json) {
    return SkillModel(
      id: json['id'] as int,
      canonicalName: json['canonicalName'] as String,
      slug: json['slug'] as String,
      aliases: (json['aliases'] as List<dynamic>?)?.map((e) => e as String).toList() ?? [],
      type: json['type'] as String,
      useCount: _parseInt(json['useCount'], 0),
      createdAt: DateTime.parse(json['createdAt']?.toString() ?? DateTime.now().toIso8601String()),
    );
  }

  static int _parseInt(dynamic value, int defaultValue) {
    if (value == null) return defaultValue;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) {
      final parsed = double.tryParse(value);
      return parsed?.toInt() ?? defaultValue;
    }
    return defaultValue;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'canonicalName': canonicalName,
      'slug': slug,
      'aliases': aliases,
      'type': type,
      'useCount': useCount,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}

class CandidateSkillModel extends CandidateSkillEntity {
  const CandidateSkillModel({
    required super.id,
    required super.candidateId,
    required super.skillMetadataId,
    super.skillMetadata,
  });

  factory CandidateSkillModel.fromJson(Map<String, dynamic> json) {
    return CandidateSkillModel(
      id: json['id'] as int,
      candidateId: json['candidateId'] as int,
      skillMetadataId: json['skillMetadataId'] as int,
      skillMetadata: json['skillMetadata'] != null
          ? SkillModel.fromJson(json['skillMetadata'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'candidateId': candidateId,
      'skillMetadataId': skillMetadataId,
    };
  }
}
