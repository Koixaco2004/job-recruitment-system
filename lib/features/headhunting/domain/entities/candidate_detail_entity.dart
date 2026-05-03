import 'package:equatable/equatable.dart';
import '../../../../features/profile/domain/entities/job_type_entity.dart';
import 'headhunting_candidate_entity.dart';

class CandidateDetailEntity extends Equatable {
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
  final int? jobTypeId;
  final JobTypeEntity? jobType;
  final int yearWorkingExperience;
  final bool isPublic;
  final String? linkedinUrl;
  final String? githubUrl;
  final String? portfolioUrl;
  final List<HeadhuntingCertificateEntity> certificates;
  final List<HeadhuntingJobCategoryEntity> jobCategories;
  final List<HeadhuntingWorkExperienceEntity> workExperiences;
  final List<HeadhuntingEducationEntity> educations;
  final List<HeadhuntingProjectEntity> projects;
  final List<HeadhuntingSkillEntity> skills;
  final bool contactUnlocked;
  final String? email;

  const CandidateDetailEntity({
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
    this.jobTypeId,
    this.jobType,
    required this.yearWorkingExperience,
    required this.isPublic,
    this.linkedinUrl,
    this.githubUrl,
    this.portfolioUrl,
    this.certificates = const [],
    this.jobCategories = const [],
    this.workExperiences = const [],
    this.educations = const [],
    this.projects = const [],
    this.skills = const [],
    this.contactUnlocked = false,
    this.email,
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
        jobTypeId,
        jobType,
        yearWorkingExperience,
        isPublic,
        linkedinUrl,
        githubUrl,
        portfolioUrl,
        certificates,
        jobCategories,
        workExperiences,
        educations,
        projects,
        skills,
        contactUnlocked,
        email,
      ];
}

class HeadhuntingWorkExperienceEntity extends Equatable {
  final int id;
  final String companyName;
  final String position;
  final DateTime? startDate;
  final DateTime? endDate;
  final bool isWorkingHere;
  final String? description;

  const HeadhuntingWorkExperienceEntity({
    required this.id,
    required this.companyName,
    required this.position,
    this.startDate,
    this.endDate,
    this.isWorkingHere = false,
    this.description,
  });

  @override
  List<Object?> get props => [id, companyName, position, startDate, endDate, isWorkingHere, description];
}

class HeadhuntingEducationEntity extends Equatable {
  final int id;
  final String schoolName;
  final String major;
  final String? degree;
  final DateTime? startDate;
  final DateTime? endDate;
  final bool isStillStudying;
  final String? description;

  const HeadhuntingEducationEntity({
    required this.id,
    required this.schoolName,
    required this.major,
    this.degree,
    this.startDate,
    this.endDate,
    this.isStillStudying = false,
    this.description,
  });

  @override
  List<Object?> get props => [id, schoolName, major, degree, startDate, endDate, isStillStudying, description];
}

class HeadhuntingProjectEntity extends Equatable {
  final int id;
  final String name;
  final DateTime? startDate;
  final DateTime? endDate;
  final String? description;

  const HeadhuntingProjectEntity({
    required this.id,
    required this.name,
    this.startDate,
    this.endDate,
    this.description,
  });

  @override
  List<Object?> get props => [id, name, startDate, endDate, description];
}

class HeadhuntingCertificateEntity extends Equatable {
  final int id;
  final String name;
  final String? cerImgUrl;

  const HeadhuntingCertificateEntity({
    required this.id,
    required this.name,
    this.cerImgUrl,
  });

  @override
  List<Object?> get props => [id, name, cerImgUrl];
}

class HeadhuntingJobCategoryEntity extends Equatable {
  final int id;
  final int jobCategoryId;
  final HeadhuntingCategoryEntity jobCategory;

  const HeadhuntingJobCategoryEntity({
    required this.id,
    required this.jobCategoryId,
    required this.jobCategory,
  });

  @override
  List<Object?> get props => [id, jobCategoryId, jobCategory];
}

class HeadhuntingCategoryEntity extends Equatable {
  final int id;
  final String name;
  final String? slug;

  const HeadhuntingCategoryEntity({
    required this.id,
    required this.name,
    this.slug,
  });

  @override
  List<Object?> get props => [id, name, slug];
}
