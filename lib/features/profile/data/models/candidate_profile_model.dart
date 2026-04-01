import '../../domain/entities/candidate_profile_entity.dart';
import 'work_experience_model.dart';
import 'education_model.dart';
import 'certificate_model.dart';
import 'project_model.dart';

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
    super.bio,
    super.cityName,
    super.provinceId,
    super.educationLevel,
    required super.yearsOfExperience,
    super.currentJobTitle,
    super.desiredJobTitle,
    super.desiredSalaryMin,
    super.desiredSalaryMax,
    super.desiredJobType,
    super.jobTypeId,
    super.skills,
    super.cvFileUrl,
    super.industry,
    super.isSearchable,
    super.workExperiences,
    super.educations,
    super.certificates,
    super.projects,
    required super.createdAt,
    required super.updatedAt,
  });

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

  static int? _parseIntNullable(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) {
      final parsed = double.tryParse(value);
      return parsed?.toInt();
    }
    return null;
  }

  static bool _parseBool(dynamic value, bool defaultValue) {
    if (value == null) return defaultValue;
    if (value is bool) return value;
    if (value is int) return value == 1;
    if (value is String) return value.toLowerCase() == 'true' || value == '1';
    return defaultValue;
  }

  static String? _parseStringNullable(dynamic value) {
    if (value == null) return null;
    if (value is String) {
      final trimmed = value.trim();
      return trimmed.isEmpty ? null : trimmed;
    }
    if (value is Map && value.containsKey('name')) {
      final name = value['name']?.toString().trim();
      return (name == null || name.isEmpty) ? null : name;
    }
    final str = value.toString().trim();
    return str.isEmpty ? null : str;
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
      gender: _mapBackendGender(json['gender'] as String?),
      bio: _parseStringNullable(json['bio'] ?? json['address']),
      cityName: _parseStringNullable(json['city_name'] ?? json['cityName']),
      provinceId: _parseIntNullable(json['province_id'] ?? json['provinceId']),
      educationLevel: _parseStringNullable(
          json['education_level'] ?? json['educationLevel']),
      yearsOfExperience: _parseInt(
          json['years_of_experience'] ??
          json['yearWorkingExperience'] ??
          json['yearsOfExperience'], 0),
      currentJobTitle: _parseStringNullable(
          json['current_job_title'] ?? json['currentJobTitle']),
      desiredJobTitle: _parseStringNullable(
          json['desired_job_title'] ?? json['position'] ?? json['desiredJobTitle']),
      desiredSalaryMin: _parseIntNullable(
          json['desired_salary_min'] ??
          json['salaryMin'] ??
          json['desiredSalaryMin']),
      desiredSalaryMax: _parseIntNullable(
          json['desired_salary_max'] ??
          json['salaryMax'] ??
          json['desiredSalaryMax']),
      desiredJobType: _parseStringNullable(
          json['desired_job_type'] ?? json['jobType'] ?? json['desiredJobType']),
      jobTypeId: _parseIntNullable(json['job_type_id'] ??
          json['jobTypeId'] ??
          (json['jobType'] is Map ? json['jobType']['id'] : null)),
      skills: json['skills'] != null
          ? (json['skills'] as List).map<String>((e) {
              if (e is String) return e;
              if (e is Map) {
                // Case CandidateSkillTagEntity mapping
                final metadata = e['skillMetadata'];
                if (metadata is Map) {
                  return metadata['canonicalName']?.toString() ?? '';
                }
                return e['name']?.toString() ?? ''; // Fallback
              }
              return e.toString();
            }).toList()
          : <String>[],
      cvFileUrl: _parseStringNullable(
          json['cv_file_url'] ?? json['cvUrl'] ?? json['cvFileUrl']),
      industry: _parseStringNullable(json['industry']),
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
      projects: json['projects'] != null
          ? (json['projects'] as List)
                .map<ProjectModel>(
                  (e) => ProjectModel.fromJson(e as Map<String, dynamic>),
                )
                .toList()
          : <ProjectModel>[],
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
      'bio': bio,
      'city_name': cityName,
      'province_id': provinceId,
      'education_level': educationLevel,
      'years_of_experience': yearsOfExperience,
      'current_job_title': currentJobTitle,
      'desired_job_title': desiredJobTitle,
      'desired_salary_min': desiredSalaryMin,
      'desired_salary_max': desiredSalaryMax,
      'desired_job_type': desiredJobType,
      'job_type_id': jobTypeId,
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
      if (bio != null) 'bio': bio,
      if (provinceId != null) 'provinceId': provinceId,
      if (desiredJobTitle != null) 'position': desiredJobTitle,
      if (desiredSalaryMin != null) 'salaryMin': desiredSalaryMin,
      if (desiredSalaryMax != null) 'salaryMax': desiredSalaryMax,
      if (jobTypeId != null) 'jobTypeId': jobTypeId,
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
      bio: entity.bio,
      cityName: entity.cityName,
      provinceId: entity.provinceId,
      educationLevel: entity.educationLevel,
      yearsOfExperience: entity.yearsOfExperience,
      currentJobTitle: entity.currentJobTitle,
      desiredJobTitle: entity.desiredJobTitle,
      desiredSalaryMin: entity.desiredSalaryMin,
      desiredSalaryMax: entity.desiredSalaryMax,
      desiredJobType: entity.desiredJobType,
      jobTypeId: entity.jobTypeId,
      skills: entity.skills,
      cvFileUrl: entity.cvFileUrl,
      industry: entity.industry,
      isSearchable: entity.isSearchable,
      workExperiences: entity.workExperiences,
      educations: entity.educations,
      certificates: entity.certificates,
      projects: entity.projects,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }

  static String? _mapBackendGender(String? backendGender) {
    if (backendGender == null) return null;
    switch (backendGender.toLowerCase()) {
      case 'male':
        return 'Nam';
      case 'female':
        return 'Nữ';
      case 'other':
        return 'Khác';
      case 'nam':
        return 'Nam';
      case 'nữ':
        return 'Nữ';
      case 'khác':
        return 'Khác';
      default:
        return backendGender;
    }
  }
}

