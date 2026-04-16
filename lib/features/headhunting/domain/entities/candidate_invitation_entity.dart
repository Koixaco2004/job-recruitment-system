import 'package:equatable/equatable.dart';

class CandidateInvitationEntity extends Equatable {
  final int id;
  final int employerId;
  final int candidateId;
  final int jobId;
  final String message;
  final String status; // 'pending', 'accepted', 'declined'
  final DateTime createdAt;
  final DateTime updatedAt;
  final InvitationEmployerEntity employer;
  final InvitationJobEntity job;

  const CandidateInvitationEntity({
    required this.id,
    required this.employerId,
    required this.candidateId,
    required this.jobId,
    required this.message,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    required this.employer,
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
        employer,
        job,
      ];
}

class InvitationEmployerEntity extends Equatable {
  final int id;
  final String fullName;
  final String? avatarUrl;
  final String? phoneContact;

  const InvitationEmployerEntity({
    required this.id,
    required this.fullName,
    this.avatarUrl,
    this.phoneContact,
  });

  @override
  List<Object?> get props => [id, fullName, avatarUrl, phoneContact];
}

class InvitationJobEntity extends Equatable {
  final int id;
  final String title;
  final double? salaryMin;
  final double? salaryMax;
  final String? currency;
  final InvitationCompanyEntity company;

  const InvitationJobEntity({
    required this.id,
    required this.title,
    this.salaryMin,
    this.salaryMax,
    this.currency,
    required this.company,
  });

  @override
  List<Object?> get props => [id, title, salaryMin, salaryMax, currency, company];
}

class InvitationCompanyEntity extends Equatable {
  final int id;
  final String name;
  final String? logoUrl;
  final String? address;

  const InvitationCompanyEntity({
    required this.id,
    required this.name,
    this.logoUrl,
    this.address,
  });

  @override
  List<Object?> get props => [id, name, logoUrl, address];
}
