import '../../../profile/data/models/job_type_model.dart';
import '../../domain/entities/headhunting_candidate_entity.dart';

class HeadhuntingCandidateModel extends HeadhuntingCandidateEntity {
  const HeadhuntingCandidateModel({
    required super.id,
    required super.userId,
    required super.fullName,
    super.gender,
    super.phone,
    super.avatarUrl,
    super.cvUrl,
    super.bio,
    super.provinceId,
    super.position,
    super.salaryMin,
    super.salaryMax,
    super.jobType,
    required super.yearsWorkingExperience,
    required super.isPublic,
    super.linkedinUrl,
    super.githubUrl,
    super.portfolioUrl,
    super.skills,
    super.matchedSkillsCount,
    super.certificateBonusCount,
    super.matchScore,
    super.scoreBreakdown,
  });

  factory HeadhuntingCandidateModel.fromJson(Map<String, dynamic> json) {
    return HeadhuntingCandidateModel(
      id: json['id'] as int? ?? 0,
      userId: json['userId'] as int? ?? 0,
      fullName: json['fullName'] as String? ?? 'Ẩn danh',
      gender: json['gender'] as String?,
      phone: json['phone'] as String?,
      avatarUrl: json['avatarUrl'] as String?,
      cvUrl: json['cvUrl'] as String?,
      bio: json['bio'] as String?,
      provinceId: json['provinceId'] as int?,
      position: json['position'] as String?,
      salaryMin: json['salaryMin'] != null ? double.tryParse(json['salaryMin'].toString()) : null,
      salaryMax: json['salaryMax'] != null ? double.tryParse(json['salaryMax'].toString()) : null,
      jobType: json['jobType'] != null ? JobTypeModel.fromJson(json['jobType'] as Map<String, dynamic>) : null,
      yearsWorkingExperience: json['yearWorkingExperience'] as int? ?? 0,
      isPublic: json['isPublic'] as bool? ?? false,
      linkedinUrl: json['linkedinUrl'] as String?,
      githubUrl: json['githubUrl'] as String?,
      portfolioUrl: json['portfolioUrl'] as String?,
      skills: (json['skills'] as List<dynamic>?)
              ?.map((e) => HeadhuntingSkillModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      matchedSkillsCount: json['matchedSkillsCount'] as int? ?? 0,
      certificateBonusCount: json['certificateBonusCount'] as int? ?? 0,
      matchScore: json['matchScore'] as int?,
      scoreBreakdown: json['scoreBreakdown'] != null
          ? ScoreBreakdownModel.fromJson(json['scoreBreakdown'] as Map<String, dynamic>)
          : null,
    );
  }
}

class ScoreBreakdownModel extends ScoreBreakdownEntity {
  const ScoreBreakdownModel({
    required super.skillScore,
    required super.experienceScore,
    required super.salaryScore,
    required super.profileScore,
    required super.locationScore,
  });

  factory ScoreBreakdownModel.fromJson(Map<String, dynamic> json) {
    return ScoreBreakdownModel(
      skillScore: json['skillScore'] as int? ?? 0,
      experienceScore: json['experienceScore'] as int? ?? 0,
      salaryScore: json['salaryScore'] as int? ?? 0,
      profileScore: json['profileScore'] as int? ?? 0,
      locationScore: json['locationScore'] as int? ?? 0,
    );
  }
}

class HeadhuntingSkillModel extends HeadhuntingSkillEntity {
  const HeadhuntingSkillModel({
    required super.id,
    required super.skillMetadataId,
    required super.skillMetadata,
  });

  factory HeadhuntingSkillModel.fromJson(Map<String, dynamic> json) {
    return HeadhuntingSkillModel(
      id: json['id'] as int? ?? 0,
      skillMetadataId: json['skillMetadataId'] as int? ?? 0,
      skillMetadata: SkillMetadataModel.fromJson(json['skillMetadata'] as Map<String, dynamic>),
    );
  }
}

class SkillMetadataModel extends SkillMetadataEntity {
  const SkillMetadataModel({
    required super.id,
    required super.canonicalName,
    required super.slug,
    required super.type,
  });

  factory SkillMetadataModel.fromJson(Map<String, dynamic> json) {
    return SkillMetadataModel(
      id: json['id'] as int? ?? 0,
      canonicalName: json['canonicalName'] as String? ?? '',
      slug: json['slug'] as String? ?? '',
      type: json['type'] as String? ?? '',
    );
  }
}
