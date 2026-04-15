import '../../domain/entities/candidate_detail_entity.dart';
import '../../../profile/data/models/job_type_model.dart';
import 'headhunting_candidate_model.dart';

class CandidateDetailModel extends CandidateDetailEntity {
  const CandidateDetailModel({
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
    super.jobTypeId,
    super.jobType,
    required super.yearWorkingExperience,
    required super.isPublic,
    super.linkedinUrl,
    super.githubUrl,
    super.portfolioUrl,
    super.certificates,
    super.jobCategories,
    super.workExperiences,
    super.educations,
    super.projects,
    super.skills,
  });

  factory CandidateDetailModel.fromJson(Map<String, dynamic> json) {
    return CandidateDetailModel(
      id: json['id'] as int,
      userId: json['userId'] as int,
      fullName: json['fullName'] as String,
      gender: json['gender'] as String?,
      phone: json['phone'] as String?,
      avatarUrl: json['avatarUrl'] as String?,
      cvUrl: json['cvUrl'] as String?,
      bio: json['bio'] as String?,
      provinceId: json['provinceId'] as int?,
      position: json['position'] as String?,
      salaryMin: json['salaryMin'] != null ? double.tryParse(json['salaryMin'].toString()) : null,
      salaryMax: json['salaryMax'] != null ? double.tryParse(json['salaryMax'].toString()) : null,
      jobTypeId: json['jobTypeId'] as int?,
      jobType: json['jobType'] != null ? JobTypeModel.fromJson(json['jobType'] as Map<String, dynamic>) : null,
      yearWorkingExperience: json['yearWorkingExperience'] as int? ?? 0,
      isPublic: json['isPublic'] as bool? ?? false,
      linkedinUrl: json['linkedinUrl'] as String?,
      githubUrl: json['githubUrl'] as String?,
      portfolioUrl: json['portfolioUrl'] as String?,
      certificates: (json['certificates'] as List<dynamic>?)
              ?.map((e) => HeadhuntingCertificateModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      jobCategories: (json['jobCategories'] as List<dynamic>?)
              ?.map((e) => HeadhuntingJobCategoryModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      workExperiences: (json['workExperiences'] as List<dynamic>?)
              ?.map((e) => HeadhuntingWorkExperienceModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      educations: (json['educations'] as List<dynamic>?)
              ?.map((e) => HeadhuntingEducationModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      projects: (json['projects'] as List<dynamic>?)
              ?.map((e) => HeadhuntingProjectModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      skills: (json['skills'] as List<dynamic>?)
              ?.map((e) => HeadhuntingSkillModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );
  }
}

class HeadhuntingWorkExperienceModel extends HeadhuntingWorkExperienceEntity {
  const HeadhuntingWorkExperienceModel({
    required super.id,
    required super.companyName,
    required super.position,
    super.startDate,
    super.endDate,
    super.isWorkingHere,
    super.description,
  });

  factory HeadhuntingWorkExperienceModel.fromJson(Map<String, dynamic> json) {
    return HeadhuntingWorkExperienceModel(
      id: json['id'] as int,
      companyName: json['companyName'] as String,
      position: json['position'] as String,
      startDate: json['startDate'] != null ? DateTime.tryParse(json['startDate'] as String) : null,
      endDate: json['endDate'] != null ? DateTime.tryParse(json['endDate'] as String) : null,
      isWorkingHere: json['isWorkingHere'] as bool? ?? false,
      description: json['description'] as String?,
    );
  }
}

class HeadhuntingEducationModel extends HeadhuntingEducationEntity {
  const HeadhuntingEducationModel({
    required super.id,
    required super.schoolName,
    required super.major,
    super.degree,
    super.startDate,
    super.endDate,
    super.isStillStudying,
    super.description,
  });

  factory HeadhuntingEducationModel.fromJson(Map<String, dynamic> json) {
    return HeadhuntingEducationModel(
      id: json['id'] as int,
      schoolName: json['schoolName'] as String,
      major: json['major'] as String,
      degree: json['degree'] as String?,
      startDate: json['startDate'] != null ? DateTime.tryParse(json['startDate'] as String) : null,
      endDate: json['endDate'] != null ? DateTime.tryParse(json['endDate'] as String) : null,
      isStillStudying: json['isStillStudying'] as bool? ?? false,
      description: json['description'] as String?,
    );
  }
}

class HeadhuntingProjectModel extends HeadhuntingProjectEntity {
  const HeadhuntingProjectModel({
    required super.id,
    required super.name,
    super.startDate,
    super.endDate,
    super.description,
  });

  factory HeadhuntingProjectModel.fromJson(Map<String, dynamic> json) {
    return HeadhuntingProjectModel(
      id: json['id'] as int,
      name: json['name'] as String,
      startDate: json['startDate'] != null ? DateTime.tryParse(json['startDate'] as String) : null,
      endDate: json['endDate'] != null ? DateTime.tryParse(json['endDate'] as String) : null,
      description: json['description'] as String?,
    );
  }
}

class HeadhuntingCertificateModel extends HeadhuntingCertificateEntity {
  const HeadhuntingCertificateModel({
    required super.id,
    required super.name,
    super.cerImgUrl,
  });

  factory HeadhuntingCertificateModel.fromJson(Map<String, dynamic> json) {
    return HeadhuntingCertificateModel(
      id: json['id'] as int,
      name: json['name'] as String,
      cerImgUrl: json['cerImgUrl'] as String?,
    );
  }
}

class HeadhuntingJobCategoryModel extends HeadhuntingJobCategoryEntity {
  const HeadhuntingJobCategoryModel({
    required super.id,
    required super.jobCategoryId,
    required super.jobCategory,
  });

  factory HeadhuntingJobCategoryModel.fromJson(Map<String, dynamic> json) {
    return HeadhuntingJobCategoryModel(
      id: json['id'] as int,
      jobCategoryId: json['jobCategoryId'] as int,
      jobCategory: HeadhuntingCategoryModel.fromJson(json['jobCategory'] as Map<String, dynamic>),
    );
  }
}

class HeadhuntingCategoryModel extends HeadhuntingCategoryEntity {
  const HeadhuntingCategoryModel({
    required super.id,
    required super.name,
    required super.slug,
  });

  factory HeadhuntingCategoryModel.fromJson(Map<String, dynamic> json) {
    return HeadhuntingCategoryModel(
      id: json['id'] as int,
      name: json['name'] as String,
      slug: json['slug'] as String,
    );
  }
}
