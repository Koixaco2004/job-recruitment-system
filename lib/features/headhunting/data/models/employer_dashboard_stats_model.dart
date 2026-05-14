import 'package:equatable/equatable.dart';

class EmployerDashboardStatsModel extends Equatable {
  final JobStatsSummary jobs;
  final ApplicationStatsSummary applications;
  final HeadhuntingStatsSummary headhunting;
  final List<TopJobModel> topJobs;

  const EmployerDashboardStatsModel({
    required this.jobs,
    required this.applications,
    required this.headhunting,
    required this.topJobs,
  });

  factory EmployerDashboardStatsModel.fromJson(Map<String, dynamic> json) {
    return EmployerDashboardStatsModel(
      jobs: JobStatsSummary.fromJson(json['jobs'] ?? {}),
      applications: ApplicationStatsSummary.fromJson(json['applications'] ?? {}),
      headhunting: HeadhuntingStatsSummary.fromJson(json['headhunting'] ?? {}),
      topJobs: (json['topJobs'] as List?)?.map((i) => TopJobModel.fromJson(i)).toList() ?? [],
    );
  }

  @override
  List<Object?> get props => [jobs, applications, headhunting, topJobs];
}

class JobStatsSummary extends Equatable {
  final int total;
  final Map<String, int> byStatus;
  final ExpiringSoonSummary expiringSoon;

  const JobStatsSummary({
    required this.total,
    required this.byStatus,
    required this.expiringSoon,
  });

  factory JobStatsSummary.fromJson(Map<String, dynamic> json) {
    return JobStatsSummary(
      total: json['total'] as int? ?? 0,
      byStatus: json['byStatus'] != null ? Map<String, int>.from(json['byStatus']) : {},
      expiringSoon: ExpiringSoonSummary.fromJson(json['expiringSoon'] ?? {}),
    );
  }

  @override
  List<Object?> get props => [total, byStatus, expiringSoon];
}

class ExpiringSoonSummary extends Equatable {
  final int count;
  final int days;

  const ExpiringSoonSummary({
    required this.count,
    required this.days,
  });

  factory ExpiringSoonSummary.fromJson(Map<String, dynamic> json) {
    return ExpiringSoonSummary(
      count: json['count'] as int? ?? 0,
      days: json['days'] as int? ?? 0,
    );
  }

  @override
  List<Object?> get props => [count, days];
}

class ApplicationStatsSummary extends Equatable {
  final int total;
  final Map<String, int> byStatus;
  final ConversionRateSummary conversionRate;
  final TrendSummary trend;

  const ApplicationStatsSummary({
    required this.total,
    required this.byStatus,
    required this.conversionRate,
    required this.trend,
  });

  factory ApplicationStatsSummary.fromJson(Map<String, dynamic> json) {
    return ApplicationStatsSummary(
      total: json['total'] as int? ?? 0,
      byStatus: json['byStatus'] != null ? Map<String, int>.from(json['byStatus']) : {},
      conversionRate: ConversionRateSummary.fromJson(json['conversionRate'] ?? {}),
      trend: TrendSummary.fromJson(json['trend'] ?? {}),
    );
  }

  @override
  List<Object?> get props => [total, byStatus, conversionRate, trend];
}

class ConversionRateSummary extends Equatable {
  final double? appliedToShortlisted;
  final double? shortlistedToInterview;
  final double? interviewToHired;

  const ConversionRateSummary({
    this.appliedToShortlisted,
    this.shortlistedToInterview,
    this.interviewToHired,
  });

  factory ConversionRateSummary.fromJson(Map<String, dynamic> json) {
    return ConversionRateSummary(
      appliedToShortlisted: json['appliedToShortlisted']?.toDouble(),
      shortlistedToInterview: json['shortlistedToInterview']?.toDouble(),
      interviewToHired: json['interviewToHired']?.toDouble(),
    );
  }

  @override
  List<Object?> get props => [appliedToShortlisted, shortlistedToInterview, interviewToHired];
}

class TrendSummary extends Equatable {
  final List<TrendDataPoint> data;

  const TrendSummary({required this.data});

  factory TrendSummary.fromJson(Map<String, dynamic> json) {
    // Backend might return 'data' or 'last7Days'
    final List<dynamic>? list = (json['data'] ?? json['last7Days']) as List<dynamic>?;
    return TrendSummary(
      data: list?.map((i) => TrendDataPoint.fromJson(i as Map<String, dynamic>)).toList() ?? [],
    );
  }

  @override
  List<Object?> get props => [data];
}

class TrendDataPoint extends Equatable {
  final String date;
  final int count;

  const TrendDataPoint({required this.date, required this.count});

  factory TrendDataPoint.fromJson(Map<String, dynamic> json) {
    return TrendDataPoint(
      date: json['date'] as String? ?? '',
      count: json['count'] as int? ?? 0,
    );
  }

  @override
  List<Object?> get props => [date, count];
}

class HeadhuntingStatsSummary extends Equatable {
  final int invitationsSent;
  final int accepted;
  final int declined;
  final int pending;
  final int savedCandidates;

  const HeadhuntingStatsSummary({
    required this.invitationsSent,
    required this.accepted,
    required this.declined,
    required this.pending,
    required this.savedCandidates,
  });

  factory HeadhuntingStatsSummary.fromJson(Map<String, dynamic> json) {
    return HeadhuntingStatsSummary(
      invitationsSent: json['invitationsSent'] as int? ?? 0,
      accepted: json['accepted'] as int? ?? 0,
      declined: json['declined'] as int? ?? 0,
      pending: json['pending'] as int? ?? 0,
      savedCandidates: json['savedCandidates'] as int? ?? 0,
    );
  }

  @override
  List<Object?> get props => [invitationsSent, accepted, declined, pending, savedCandidates];
}

class TopJobModel extends Equatable {
  final int jobId;
  final String title;
  final String status;
  final int applicationCount;

  const TopJobModel({
    required this.jobId,
    required this.title,
    required this.status,
    required this.applicationCount,
  });

  factory TopJobModel.fromJson(Map<String, dynamic> json) {
    return TopJobModel(
      jobId: json['jobId'] as int? ?? 0,
      title: json['title'] as String? ?? '',
      status: json['status'] as String? ?? '',
      applicationCount: json['applicationCount'] as int? ?? 0,
    );
  }

  @override
  List<Object?> get props => [jobId, title, status, applicationCount];
}
