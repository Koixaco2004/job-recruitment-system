import 'package:equatable/equatable.dart';

/// Entity đại diện cho đơn ứng tuyển (bảng APPLICATIONS)
class ApplicationEntity extends Equatable {
  final int? applicationId;
  final int jobPostId;
  final int candidateId;
  final String? cvFileUrl;
  final String? coverLetter;
  final String
  status; // 'submitted', 'viewed', 'interview_scheduled', 'rejected', 'hired'
  final DateTime appliedAt;
  final DateTime? viewedAt;
  final DateTime? updatedAt;

  // Thông tin bổ sung từ join
  final String? jobTitle;
  final String? companyName;

  const ApplicationEntity({
    this.applicationId,
    required this.jobPostId,
    required this.candidateId,
    this.cvFileUrl,
    this.coverLetter,
    required this.status,
    required this.appliedAt,
    this.viewedAt,
    this.updatedAt,
    this.jobTitle,
    this.companyName,
  });

  @override
  List<Object?> get props => [
    applicationId,
    jobPostId,
    candidateId,
    cvFileUrl,
    coverLetter,
    status,
    appliedAt,
    viewedAt,
    updatedAt,
  ];
}
