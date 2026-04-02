import 'package:equatable/equatable.dart';

/// Entity đại diện cho Job Post (dựa trên bảng JOB_POSTS)
class JobPostEntity extends Equatable {
  final int jobPostId;
  final int employerId;
  final String title;
  final String description;
  final String requirements;
  final String benefits;
  final String jobType; // 'fulltime', 'parttime', 'remote', 'freelance'
  final int? salaryMin;
  final int? salaryMax;
  final String salaryType; // 'VND', 'USD', 'negotiable'
  final int numberOfPositions;
  final int experienceRequired;
  final DateTime deadline;
  final String status; // 'pending', 'approved', 'rejected', 'closed', 'expired'
  final bool isPriority;
  final int viewCount;
  final int applicationCount;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? rejectionReason;

  // Thông tin công ty (từ join với EMPLOYERS)
  final String companyName;
  final String? companyLogo;

  // Thông tin địa điểm (từ join với CITIES)
  final String cityName;

  // Thông tin ngành nghề (từ join với INDUSTRIES)
  final String industryName;

  final int? provinceId;
  final int? categoryId;
  final int? jobTypeId;
  final List<dynamic>? skills;

  const JobPostEntity({
    required this.jobPostId,
    required this.employerId,
    required this.title,
    required this.description,
    required this.requirements,
    required this.benefits,
    required this.jobType,
    this.salaryMin,
    this.salaryMax,
    required this.salaryType,
    required this.numberOfPositions,
    required this.experienceRequired,
    required this.deadline,
    required this.status,
    required this.isPriority,
    required this.viewCount,
    required this.applicationCount,
    required this.createdAt,
    required this.updatedAt,
    required this.companyName,
    this.companyLogo,
    required this.cityName,
    required this.industryName,
    this.provinceId,
    this.categoryId,
    this.jobTypeId,
    this.skills,
    this.rejectionReason,
  });

  @override
  List<Object?> get props => [
    jobPostId,
    employerId,
    title,
    description,
    requirements,
    benefits,
    jobType,
    salaryMin,
    salaryMax,
    salaryType,
    numberOfPositions,
    experienceRequired,
    deadline,
    status,
    isPriority,
    viewCount,
    applicationCount,
    createdAt,
    updatedAt,
    companyName,
    companyLogo,
    cityName,
    industryName,
    provinceId,
    categoryId,
    jobTypeId,
    skills,
    rejectionReason,
  ];
}
