import 'package:equatable/equatable.dart';
import '../../domain/entities/employer_invitation_entity.dart';

class EmployerInvitationModel extends EmployerInvitationEntity {
  const EmployerInvitationModel({
    required super.id,
    required super.employerId,
    required super.candidateId,
    required super.jobId,
    required super.message,
    required super.status,
    required super.createdAt,
    required super.updatedAt,
    required super.candidate,
    required super.job,
  });

  factory EmployerInvitationModel.fromJson(Map<String, dynamic> json) {
    return EmployerInvitationModel(
      id: json['id'] ?? 0,
      employerId: json['employerId'] ?? 0,
      candidateId: json['candidateId'] ?? 0,
      jobId: json['jobId'] ?? 0,
      message: json['message'] ?? '',
      status: json['status'] ?? 'pending',
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : DateTime.now(),
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : DateTime.now(),
      candidate: json['candidate'] != null 
          ? InvitationCandidateModel.fromJson(json['candidate'])
          : const InvitationCandidateModel(id: 0, userId: 0, fullName: 'Unknown Candidate'),
      job: json['job'] != null 
          ? InvitationJobModel.fromJson(json['job'])
          : InvitationJobModel(jobPostId: json['jobId'] ?? 0, title: 'Unknown Job'),
    );
  }
}

class InvitationCandidateModel extends InvitationCandidateEntity {
  const InvitationCandidateModel({
    required super.id,
    required super.userId,
    required super.fullName,
    super.avatarUrl,
    super.position,
    super.phone,
    super.salaryMin,
    super.salaryMax,
    super.bio,
  });

  factory InvitationCandidateModel.fromJson(Map<String, dynamic> json) {
    return InvitationCandidateModel(
      id: json['id'] ?? 0,
      userId: json['userId'] ?? 0,
      fullName: json['fullName'] ?? 'Unknown Candidate',
      avatarUrl: json['avatarUrl'],
      position: json['position'],
      phone: json['phone'],
      salaryMin: json['salaryMin'] != null ? double.tryParse(json['salaryMin'].toString()) : null,
      salaryMax: json['salaryMax'] != null ? double.tryParse(json['salaryMax'].toString()) : null,
      bio: json['bio'],
    );
  }
}

class InvitationJobModel extends InvitationJobEntity {
  const InvitationJobModel({
    required super.jobPostId,
    required super.title,
  });

  factory InvitationJobModel.fromJson(Map<String, dynamic> json) {
    return InvitationJobModel(
      jobPostId: json['id'] ?? json['jobPostId'] ?? 0,
      title: json['title'] ?? 'Unknown Job',
    );
  }
}
