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

  static int _parseInt(dynamic value, int defaultValue) {
    if (value == null) return defaultValue;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value) ?? defaultValue;
    return defaultValue;
  }

  static int? _parseIntNullable(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value);
    return null;
  }

  static bool _parseBool(dynamic value, bool defaultValue) {
    if (value == null) return defaultValue;
    if (value is bool) return value;
    if (value is int) return value == 1;
    if (value is String) return value.toLowerCase() == 'true' || value == '1';
    return defaultValue;
  }

  factory CandidateProfileModel.fromJson(Map<String, dynamic> json) {
    return CandidateProfileModel(
      userId: _parseInt(json['user_id'] ?? json['userId'], 0),
      email: json['email'] ?? '',
      phone: json['phone']?.toString(),
      fullName: json['full_name'] ?? json['fullName'] ?? '',
      avatarUrl: json['avatar_url'] ?? json['avatarUrl']?.toString(),
      candidateId: _parseInt(json['candidate_id'] ?? json['id'] ?? json['candidateId'], 0),
      dateOfBirth: (json['date_of_birth'] ?? json['dateOfBirth']) != null
          ? DateTime.parse(json['date_of_birth'] ?? json['dateOfBirth'])
          : null,
      gender: json['gender'] as String?,
      address: json['address']?.toString(),
      cityName: json['city_name'] ?? json['cityName']?.toString(),
      educationLevel:
          json['education_level'] ?? json['educationLevel']?.toString(),
      yearsOfExperience: _parseInt(
          json['years_of_experience'] ??
          json['yearWorkingExperience'] ??
          json['yearsOfExperience'], 0),
      currentJobTitle:
          json['current_job_title'] ?? json['currentJobTitle']?.toString(),
      desiredJobTitle:
          json['desired_job_title'] ??
          json['position'] ??
          json['desiredJobTitle']?.toString(),
      desiredSalaryMin: _parseIntNullable(
          json['desired_salary_min'] ??
          json['salaryMin'] ??
          json['desiredSalaryMin']),
      desiredSalaryMax: _parseIntNullable(
          json['desired_salary_max'] ??
          json['salaryMax'] ??
          json['desiredSalaryMax']),
      desiredJobType:
          json['desired_job_type'] ??
          json['jobType'] ??
          json['desiredJobType']
              ?.toString(), // Note: backend dto takes jobTypeId in PUT, but might return jobType object or string
      skills: json['skills'] != null
          ? List<String>.from(json['skills'])
          : <String>[],
      cvFileUrl:
          json['cv_file_url'] ?? json['cvUrl'] ?? json['cvFileUrl']?.toString(),
      industry: json['industry']?.toString(),
      isSearchable: _parseBool(json['is_searchable'] ?? json['isSearchable'], false),
      workExperiences:
          json['work_experiences'] ?? json['workExperiences'] != null
          ? (json['work_experiences'] ?? json['workExperiences'] as List)
                .map<WorkExperienceModel>(
                  (e) =>
                      WorkExperienceModel.fromJson(e as Map<String, dynamic>),
                )
                .toList()
          : <WorkExperienceModel>[],
      educations: json['educations'] != null
          ? (json['educations'] as List)
                .map<EducationModel>(
                  (e) => EducationModel.fromJson(e as Map<String, dynamic>),
                )
                .toList()
          : <EducationModel>[],
      certificates: json['certificates'] != null
          ? (json['certificates'] as List)
                .map<CertificateModel>(
                  (e) => CertificateModel.fromJson(e as Map<String, dynamic>),
                )
                .toList()
          : <CertificateModel>[],
      languages: json['languages'] != null
          ? (json['languages'] as List)
                .map<LanguageModel>(
                  (e) => LanguageModel.fromJson(e as Map<String, dynamic>),
                )
                .toList()
          : <LanguageModel>[],
      createdAt: (json['created_at'] ?? json['createdAt']) != null
          ? DateTime.parse(json['created_at'] ?? json['createdAt'])
          : DateTime.now(),
      updatedAt: (json['updated_at'] ?? json['updatedAt']) != null
          ? DateTime.parse(json['updated_at'] ?? json['updatedAt'])
          : DateTime.now(),
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

  /// Create JSON body matching UpdateProfileDto spec from backend
  Map<String, dynamic> toUpdateProfileDto() {
    return {
      if (fullName.isNotEmpty) 'fullName': fullName,
      if (gender != null)
        'gender': gender == 'Nam'
            ? 'male'
            : gender == 'Nữ'
            ? 'female'
            : 'other',
      if (phone != null) 'phone': phone,
      if (avatarUrl != null) 'avatarUrl': avatarUrl,
      if (cvFileUrl != null) 'cvUrl': cvFileUrl,
      if (address != null) 'bio': address,
      // 'provinceId': null, // Need integer provinceId, current city is String
      if (desiredJobTitle != null) 'position': desiredJobTitle,
      if (desiredSalaryMin != null) 'salaryMin': desiredSalaryMin,
      if (desiredSalaryMax != null) 'salaryMax': desiredSalaryMax,
      // 'jobTypeId': 1, // Fallback placeholder since backend expects number
      'yearWorkingExperience': yearsOfExperience,
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
