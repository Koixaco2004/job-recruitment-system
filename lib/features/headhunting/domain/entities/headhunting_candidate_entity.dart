import 'package:equatable/equatable.dart';
import '../../../../features/profile/domain/entities/job_type_entity.dart';

class HeadhuntingCandidateEntity extends Equatable {
  final int id;
  final int userId;
  final String fullName;
  final String? gender;
  final String? phone;
  final String? avatarUrl;
  final String? cvUrl;
  final String? bio;
  final int? provinceId;
  final String? position;
  final double? salaryMin;
  final double? salaryMax;
  final JobTypeEntity? jobType;
  final int yearsWorkingExperience;
  final bool isPublic;
  final String? linkedinUrl;
  final String? githubUrl;
  final String? portfolioUrl;
  final List<HeadhuntingSkillEntity> skills;
  final int matchedSkillsCount;
  final int certificateBonusCount;
  final int? matchScore;
  final ScoreBreakdownEntity? scoreBreakdown;

  const HeadhuntingCandidateEntity({
    required this.id,
    required this.userId,
    required this.fullName,
    this.gender,
    this.phone,
    this.avatarUrl,
    this.cvUrl,
    this.bio,
    this.provinceId,
    this.position,
    this.salaryMin,
    this.salaryMax,
    this.jobType,
    required this.yearsWorkingExperience,
    required this.isPublic,
    this.linkedinUrl,
    this.githubUrl,
    this.portfolioUrl,
    this.skills = const [],
    this.matchedSkillsCount = 0,
    this.certificateBonusCount = 0,
    this.matchScore,
    this.scoreBreakdown,
  });

  @override
  List<Object?> get props => [
        id,
        userId,
        fullName,
        gender,
        phone,
        avatarUrl,
        cvUrl,
        bio,
        provinceId,
        position,
        salaryMin,
        salaryMax,
        jobType,
        yearsWorkingExperience,
        isPublic,
        linkedinUrl,
        githubUrl,
        portfolioUrl,
        skills,
        matchedSkillsCount,
        certificateBonusCount,
        matchScore,
        scoreBreakdown,
      ];
}

class ScoreBreakdownEntity extends Equatable {
  final int skillScore;
  final int experienceScore;
  final int salaryScore;
  final int profileScore;
  final int locationScore;

  const ScoreBreakdownEntity({
    required this.skillScore,
    required this.experienceScore,
    required this.salaryScore,
    required this.profileScore,
    required this.locationScore,
  });

  @override
  List<Object?> get props => [
        skillScore,
        experienceScore,
        salaryScore,
        profileScore,
        locationScore,
      ];
}

class HeadhuntingSkillEntity extends Equatable {
  final int id;
  final int skillMetadataId;
  final SkillMetadataEntity skillMetadata;

  const HeadhuntingSkillEntity({
    required this.id,
    required this.skillMetadataId,
    required this.skillMetadata,
  });

  @override
  List<Object?> get props => [id, skillMetadataId, skillMetadata];
}

class SkillMetadataEntity extends Equatable {
  final int id;
  final String canonicalName;
  final String slug;
  final String type; // 'hard' or 'soft'

  const SkillMetadataEntity({
    required this.id,
    required this.canonicalName,
    required this.slug,
    required this.type,
  });

  @override
  List<Object?> get props => [id, canonicalName, slug, type];
}
