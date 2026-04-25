import 'package:equatable/equatable.dart';
import 'employer_dashboard_stats_model.dart';

class JobDetailedStatsModel extends Equatable {
  final JobInfo job;
  final ApplicationStatsSummary applications;
  final InvitationStatsSummary invitations;

  const JobDetailedStatsModel({
    required this.job,
    required this.applications,
    required this.invitations,
  });

  factory JobDetailedStatsModel.fromJson(Map<String, dynamic> json) {
    return JobDetailedStatsModel(
      job: JobInfo.fromJson(json['job']),
      applications: ApplicationStatsSummary.fromJson(json['applications']),
      invitations: InvitationStatsSummary.fromJson(json['invitations']),
    );
  }

  @override
  List<Object?> get props => [job, applications, invitations];
}

class JobInfo extends Equatable {
  final int id;
  final String title;
  final String status;
  final String deadline;
  final int slots;

  const JobInfo({
    required this.id,
    required this.title,
    required this.status,
    required this.deadline,
    required this.slots,
  });

  factory JobInfo.fromJson(Map<String, dynamic> json) {
    return JobInfo(
      id: json['id'],
      title: json['title'],
      status: json['status'],
      deadline: json['deadline'],
      slots: json['slots'],
    );
  }

  @override
  List<Object?> get props => [id, title, status, deadline, slots];
}

class InvitationStatsSummary extends Equatable {
  final int sent;
  final int accepted;
  final int declined;
  final int pending;

  const InvitationStatsSummary({
    required this.sent,
    required this.accepted,
    required this.declined,
    required this.pending,
  });

  factory InvitationStatsSummary.fromJson(Map<String, dynamic> json) {
    return InvitationStatsSummary(
      sent: json['sent'],
      accepted: json['accepted'],
      declined: json['declined'],
      pending: json['pending'],
    );
  }

  @override
  List<Object?> get props => [sent, accepted, declined, pending];
}
