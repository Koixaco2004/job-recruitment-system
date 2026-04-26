import 'package:equatable/equatable.dart';
import 'job_post_entity.dart';

/// Entity cho việc làm đã lưu (SAVED_JOBS table)
class SavedJobEntity extends Equatable {
  final int savedJobId;
  final int candidateId;
  final int jobPostId;
  final DateTime createdAt;
  final JobPostEntity? job;

  // Thông tin job (từ join - legacy support)
  final String? jobTitle;
  final String? companyName;
  final String? companyLogo;
  final String? cityName;
  final int? salaryMin;
  final int? salaryMax;
  final String? salaryType;
  final String? jobType;
  final String? jobLevel;
  final DateTime? deadline;

  const SavedJobEntity({
    required this.savedJobId,
    required this.candidateId,
    required this.jobPostId,
    required this.createdAt,
    this.job,
    this.jobTitle,
    this.companyName,
    this.companyLogo,
    this.cityName,
    this.salaryMin,
    this.salaryMax,
    this.salaryType,
    this.jobType,
    this.jobLevel,
    this.deadline,
  });

  @override
  List<Object?> get props => [savedJobId, candidateId, jobPostId, createdAt, job];
}
