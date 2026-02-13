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
  final String
  jobLevel; // 'intern', 'fresher', 'junior', 'middle', 'senior', 'leader', 'manager'
  final int? salaryMin;
  final int? salaryMax;
  final String salaryType; // 'VND', 'USD', 'negotiable'
  final int numberOfPositions;
  final int experienceRequired;
  final String? educationRequired;
  final String? address;
  final DateTime deadline;
  final String status; // 'pending', 'approved', 'rejected', 'closed', 'expired'
  final bool isPriority;
  final int viewCount;
  final int applicationCount;
  final DateTime createdAt;
  final DateTime updatedAt;

  // Thông tin công ty (từ join với EMPLOYERS)
  final String companyName;
  final String? companyLogo;

  // Thông tin địa điểm (từ join với CITIES)
  final String cityName;

  // Thông tin ngành nghề (từ join với INDUSTRIES)
  final String industryName;

  const JobPostEntity({
    required this.jobPostId,
    required this.employerId,
    required this.title,
    required this.description,
    required this.requirements,
    required this.benefits,
    required this.jobType,
    required this.jobLevel,
    this.salaryMin,
    this.salaryMax,
    required this.salaryType,
    required this.numberOfPositions,
    required this.experienceRequired,
    this.educationRequired,
    this.address,
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
    jobLevel,
    salaryMin,
    salaryMax,
    salaryType,
    numberOfPositions,
    experienceRequired,
    educationRequired,
    address,
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
  ];
}
