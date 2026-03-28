import 'package:equatable/equatable.dart';

/// Thực thể đại diện cho Metadata của một Skill trong hệ thống
class SkillEntity extends Equatable {
  final int id;
  final String canonicalName;
  final String slug;
  final List<String> aliases;
  final String type; // 'hard' hoặc 'soft'
  final int useCount;
  final DateTime createdAt;

  const SkillEntity({
    required this.id,
    required this.canonicalName,
    required this.slug,
    this.aliases = const [],
    required this.type,
    this.useCount = 0,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [id, canonicalName, slug, aliases, type, useCount, createdAt];
}

/// Thực thể đại diện cho bản ghi mapping giữa Candidate và Skill (candidate_skill_tag)
class CandidateSkillEntity extends Equatable {
  final int id; // ID của bản ghi mapping (candidate_skill_tag ID)
  final int candidateId;
  final int skillMetadataId;
  final SkillEntity? skillMetadata;

  const CandidateSkillEntity({
    required this.id,
    required this.candidateId,
    required this.skillMetadataId,
    this.skillMetadata,
  });

  @override
  List<Object?> get props => [id, candidateId, skillMetadataId, skillMetadata];
}
