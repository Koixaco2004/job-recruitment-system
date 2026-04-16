import '../../domain/entities/candidate_invitation_entity.dart';

class CandidateInvitationModel extends CandidateInvitationEntity {
  const CandidateInvitationModel({
    required super.id,
    required super.employerId,
    required super.candidateId,
    required super.jobId,
    required super.message,
    required super.status,
    required super.createdAt,
    required super.updatedAt,
    required super.employer,
    required super.job,
  });

  factory CandidateInvitationModel.fromJson(Map<String, dynamic> json) {
    return CandidateInvitationModel(
      id: json['id'],
      employerId: json['employerId'],
      candidateId: json['candidateId'],
      jobId: json['jobId'],
      message: json['message'] ?? '',
      status: json['status'] ?? 'pending',
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      employer: InvitationEmployerModel.fromJson(json['employer']),
      job: InvitationJobModel.fromJson(json['job']),
    );
  }
}

class InvitationEmployerModel extends InvitationEmployerEntity {
  const InvitationEmployerModel({
    required super.id,
    required super.fullName,
    super.avatarUrl,
    super.phoneContact,
  });

  factory InvitationEmployerModel.fromJson(Map<String, dynamic> json) {
    return InvitationEmployerModel(
      id: json['id'],
      fullName: json['fullName'] ?? '',
      avatarUrl: json['avatarUrl'],
      phoneContact: json['phoneContact'],
    );
  }
}

class InvitationJobModel extends InvitationJobEntity {
  const InvitationJobModel({
    required super.id,
    required super.title,
    super.salaryMin,
    super.salaryMax,
    super.currency,
    required super.company,
  });

  factory InvitationJobModel.fromJson(Map<String, dynamic> json) {
    return InvitationJobModel(
      id: json['id'],
      title: json['title'] ?? '',
      salaryMin: json['salaryMin'] != null ? double.tryParse(json['salaryMin'].toString()) : null,
      salaryMax: json['salaryMax'] != null ? double.tryParse(json['salaryMax'].toString()) : null,
      currency: json['currency'],
      company: InvitationCompanyModel.fromJson(json['company']),
    );
  }
}

class InvitationCompanyModel extends InvitationCompanyEntity {
  const InvitationCompanyModel({
    required super.id,
    required super.name,
    super.logoUrl,
    super.address,
  });

  factory InvitationCompanyModel.fromJson(Map<String, dynamic> json) {
    return InvitationCompanyModel(
      id: json['id'],
      name: json['name'] ?? '',
      logoUrl: json['logoUrl'],
      address: json['address'],
    );
  }
}
