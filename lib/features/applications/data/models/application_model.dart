import '../../domain/entities/application_entity.dart';
import '../../../jobs/data/models/job_post_model.dart';
import '../../../profile/data/models/candidate_profile_model.dart';
import 'application_status_history_model.dart';
import 'application_note_model.dart';


class ApplicationModel extends ApplicationEntity {
  const ApplicationModel({
    required super.id,
    required super.jobId,
    required super.candidateId,
    super.cvUrlSnapshot,
    super.coverLetter,
    required super.status,
    super.rejectionReason,
    super.employerNote,
    super.matchScore,
    super.matchReasoning,
    super.cvMatchScore,
    super.cvMatchReasoning,
    required super.appliedAt,
    required super.updatedAt,
    super.job,
    super.candidate,
    super.statusHistory,
    super.notes,
  });

  factory ApplicationModel.fromJson(Map<String, dynamic> json) {
    return ApplicationModel(
      id: _asInt(json['id']),
      jobId: _asInt(json['jobId'] ?? json['job_id']),
      candidateId: _asInt(json['candidateId'] ?? json['candidate_id']),
      cvUrlSnapshot: json['cvUrlSnapshot'] as String?,
      coverLetter: json['coverLetter'] as String?,
      status: json['status'] as String? ?? 'applied',
      rejectionReason: json['rejectionReason'] as String?,
      employerNote: json['employerNote'] as String?,
      matchScore: _asDouble(json['matchScore']),
      matchReasoning: json['matchReasoning'] as String?,
      cvMatchScore: _asDouble(json['cvMatchScore']),
      cvMatchReasoning: json['cvMatchReasoning'] as String?,
      appliedAt: json['appliedAt'] != null
          ? DateTime.parse(json['appliedAt'] as String)
          : (json['created_at'] != null ? DateTime.parse(json['created_at'] as String) : DateTime.now()),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : (json['updated_at'] != null ? DateTime.parse(json['updated_at'] as String) : DateTime.now()),
      job: json['job'] != null ? JobPostModel.fromJson(json['job']) : null,
      candidate: json['candidate'] != null
          ? CandidateProfileModel.fromJson(json['candidate'])
          : null,
      statusHistory: json['statusHistory'] != null
          ? (json['statusHistory'] as List)
              .map((e) => ApplicationStatusHistoryModel.fromJson(e))
              .toList()
          : null,
      notes: json['notes'] != null
          ? (json['notes'] as List)
              .map((e) => ApplicationNoteModel.fromJson(e))
              .toList()
          : null,
    );
  }

  static int _asInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is String) return int.tryParse(value) ?? 0;
    if (value is double) return value.toInt();
    return 0;
  }

  static double? _asDouble(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'jobId': jobId,
      'candidateId': candidateId,
      'cvUrlSnapshot': cvUrlSnapshot,
      'coverLetter': coverLetter,
      'status': status,
      'rejectionReason': rejectionReason,
      'employerNote': employerNote,
      'matchScore': matchScore,
      'matchReasoning': matchReasoning,
      'cvMatchScore': cvMatchScore,
      'cvMatchReasoning': cvMatchReasoning,
      'appliedAt': appliedAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}
