import '../../domain/entities/candidate_profile_entity.dart';
import 'work_experience_model.dart';
import 'education_model.dart';
import 'certificate_model.dart';
import 'language_model.dart';

class CandidateProfileModel extends CandidateProfileEntity {
  const CandidateProfileModel({
    required super.userId,
    required super.email,
    super.phone,
    required super.fullName,
    super.avatarUrl,
    required super.candidateId,
    super.dateOfBirth,
    super.gender,
    super.address,
    super.cityName,
    super.educationLevel,
    required super.yearsOfExperience,
    super.currentJobTitle,
    super.desiredJobTitle,
    super.desiredSalaryMin,
    super.desiredSalaryMax,
    super.desiredJobType,
    super.skills,
    super.cvFileUrl,
    super.industry,
    super.isSearchable,
    super.workExperiences,
    super.educations,
    super.certificates,
    super.languages,
    required super.createdAt,
    required super.updatedAt,
  });

  factory CandidateProfileModel.fromJson(Map<String, dynamic> json) {
    return CandidateProfileModel(
      userId: json['user_id'] as int,
      email: json['email'] as String,
      phone: json['phone'] as String?,
      fullName: json['full_name'] as String,
      avatarUrl: json['avatar_url'] as String?,
      candidateId: json['candidate_id'] as int,
      dateOfBirth: json['date_of_birth'] != null
          ? DateTime.parse(json['date_of_birth'] as String)
          : null,
      gender: json['gender'] as String?,
      address: json['address'] as String?,
      cityName: json['city_name'] as String?,
      educationLevel: json['education_level'] as String?,
      yearsOfExperience: json['years_of_experience'] as int? ?? 0,
      currentJobTitle: json['current_job_title'] as String?,
      desiredJobTitle: json['desired_job_title'] as String?,
      desiredSalaryMin: json['desired_salary_min'] as int?,
      desiredSalaryMax: json['desired_salary_max'] as int?,
      desiredJobType: json['desired_job_type'] as String?,
      skills: json['skills'] != null
          ? List<String>.from(json['skills'] as List)
          : [],
      cvFileUrl: json['cv_file_url'] as String?,
      industry: json['industry'] as String?,
      isSearchable: json['is_searchable'] as bool? ?? false,
      workExperiences: json['work_experiences'] != null
          ? (json['work_experiences'] as List)
                .map(
                  (e) =>
                      WorkExperienceModel.fromJson(e as Map<String, dynamic>),
                )
                .toList()
          : [],
      educations: json['educations'] != null
          ? (json['educations'] as List)
                .map((e) => EducationModel.fromJson(e as Map<String, dynamic>))
                .toList()
          : [],
      certificates: json['certificates'] != null
          ? (json['certificates'] as List)
                .map(
                  (e) => CertificateModel.fromJson(e as Map<String, dynamic>),
                )
                .toList()
          : [],
      languages: json['languages'] != null
          ? (json['languages'] as List)
                .map((e) => LanguageModel.fromJson(e as Map<String, dynamic>))
                .toList()
          : [],
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'email': email,
      'phone': phone,
      'full_name': fullName,
      'avatar_url': avatarUrl,
      'candidate_id': candidateId,
      'date_of_birth': dateOfBirth?.toIso8601String(),
      'gender': gender,
      'address': address,
      'city_name': cityName,
      'education_level': educationLevel,
      'years_of_experience': yearsOfExperience,
      'current_job_title': currentJobTitle,
      'desired_job_title': desiredJobTitle,
      'desired_salary_min': desiredSalaryMin,
      'desired_salary_max': desiredSalaryMax,
      'desired_job_type': desiredJobType,
      'skills': skills,
      'cv_file_url': cvFileUrl,
      'industry': industry,
      'is_searchable': isSearchable,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  /// Create from entity (for updates)
  factory CandidateProfileModel.fromEntity(CandidateProfileEntity entity) {
    return CandidateProfileModel(
      userId: entity.userId,
      email: entity.email,
      phone: entity.phone,
      fullName: entity.fullName,
      avatarUrl: entity.avatarUrl,
      candidateId: entity.candidateId,
      dateOfBirth: entity.dateOfBirth,
      gender: entity.gender,
      address: entity.address,
      cityName: entity.cityName,
      educationLevel: entity.educationLevel,
      yearsOfExperience: entity.yearsOfExperience,
      currentJobTitle: entity.currentJobTitle,
      desiredJobTitle: entity.desiredJobTitle,
      desiredSalaryMin: entity.desiredSalaryMin,
      desiredSalaryMax: entity.desiredSalaryMax,
      desiredJobType: entity.desiredJobType,
      skills: entity.skills,
      cvFileUrl: entity.cvFileUrl,
      industry: entity.industry,
      isSearchable: entity.isSearchable,
      workExperiences: entity.workExperiences,
      educations: entity.educations,
      certificates: entity.certificates,
      languages: entity.languages,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }
}
