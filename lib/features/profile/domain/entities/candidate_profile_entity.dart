import 'package:equatable/equatable.dart';
import 'work_experience_entity.dart';
import 'education_entity.dart';
import 'certificate_entity.dart';
import 'language_entity.dart';

/// Entity tổng hợp hồ sơ ứng viên (USERS + CANDIDATES)
class CandidateProfileEntity extends Equatable {
  // === Thông tin từ bảng USERS ===
  final int userId;
  final String email;
  final String? phone;
  final String fullName;
  final String? avatarUrl;

  // === Thông tin từ bảng CANDIDATES ===
  final int candidateId;
  final DateTime? dateOfBirth;
  final String? gender;
  final String? address;
  final String? cityName;
  final String? educationLevel;
  final int yearsOfExperience;
  final String? currentJobTitle;
  final String? desiredJobTitle;
  final int? desiredSalaryMin;
  final int? desiredSalaryMax;
  final String? desiredJobType;
  final List<String> skills;
  final String? cvFileUrl;
  final String? industry; // Ngành nghề của ứng viên
  final bool isSearchable; // Trạng thái tìm việc (công khai/riêng tư)

  // === Danh sách chi tiết ===
  final List<WorkExperienceEntity> workExperiences;
  final List<EducationEntity> educations;
  final List<CertificateEntity> certificates;
  final List<LanguageEntity> languages;

  final DateTime createdAt;
  final DateTime updatedAt;

  const CandidateProfileEntity({
    required this.userId,
    required this.email,
    this.phone,
    required this.fullName,
    this.avatarUrl,
    required this.candidateId,
    this.dateOfBirth,
    this.gender,
    this.address,
    this.cityName,
    this.educationLevel,
    required this.yearsOfExperience,
    this.currentJobTitle,
    this.desiredJobTitle,
    this.desiredSalaryMin,
    this.desiredSalaryMax,
    this.desiredJobType,
    this.skills = const [],
    this.cvFileUrl,
    this.industry,
    this.isSearchable = false,
    this.workExperiences = const [],
    this.educations = const [],
    this.certificates = const [],
    this.languages = const [],
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  List<Object?> get props => [
    userId,
    email,
    phone,
    fullName,
    avatarUrl,
    candidateId,
    dateOfBirth,
    gender,
    address,
    cityName,
    educationLevel,
    yearsOfExperience,
    currentJobTitle,
    desiredJobTitle,
    desiredSalaryMin,
    desiredSalaryMax,
    desiredJobType,
    skills,
    cvFileUrl,
    industry,
    isSearchable,
    workExperiences,
    educations,
    certificates,
    languages,
    createdAt,
    updatedAt,
  ];
}
