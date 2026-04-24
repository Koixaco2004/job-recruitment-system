import '../../../profile/domain/entities/skill_entity.dart';

class SkillModel extends SkillEntity {
  const SkillModel({
    required super.id,
    required super.canonicalName,
    required super.slug,
    super.aliases = const [],
    required super.type,
    super.useCount = 0,
    required super.createdAt,
  });

  factory SkillModel.fromJson(Map<String, dynamic> json) {
    return SkillModel(
      id: json['id'],
      canonicalName: json['canonicalName'],
      slug: json['slug'],
      aliases: json['aliases'] != null ? List<String>.from(json['aliases']) : const [],
      type: json['type'] ?? 'hard',
      useCount: json['useCount'] ?? 0,
      createdAt: json['createdAt'] != null 
          ? DateTime.parse(json['createdAt']) 
          : DateTime.now(),
    );
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
