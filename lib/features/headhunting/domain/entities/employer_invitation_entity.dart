import 'package:equatable/equatable.dart';

class EmployerInvitationEntity extends Equatable {
  final int id;
  final int employerId;
  final int candidateId;
  final int jobId;
  final String message;
  final String status;
  final DateTime createdAt;
  final DateTime updatedAt;
  final InvitationCandidateEntity candidate;
  final InvitationJobEntity job;

  const EmployerInvitationEntity({
    required this.id,
    required this.employerId,
    required this.candidateId,
    required this.jobId,
    required this.message,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    required this.candidate,
    required this.job,
  });

  @override
  List<Object?> get props => [
        id,
        employerId,
        candidateId,
        jobId,
        message,
        status,
        createdAt,
        updatedAt,
        candidate,
        job,
      ];
}

class InvitationCandidateEntity extends Equatable {
  final int id;
  final int userId;
  final String fullName;
  final String? avatarUrl;
  final String? position;
  final String? phone;
  final double? salaryMin;
  final double? salaryMax;
  final String? bio;

  const InvitationCandidateEntity({
    required this.id,
    required this.userId,
    required this.fullName,
    this.avatarUrl,
    this.position,
    this.phone,
    this.salaryMin,
    this.salaryMax,
    this.bio,
  });

  @override
  List<Object?> get props => [
        id,
        userId,
        fullName,
        avatarUrl,
        position,
        phone,
        salaryMin,
        salaryMax,
        bio,
      ];
}

class InvitationJobEntity extends Equatable {
  final int jobPostId;
  final String title;

  const InvitationJobEntity({
    required this.jobPostId,
    required this.title,
  });

  @override
  List<Object?> get props => [jobPostId, title];
}
