import 'package:equatable/equatable.dart';
import '../../../jobs/domain/entities/job_post_entity.dart';
import '../../../profile/domain/entities/candidate_profile_entity.dart';

import 'application_status_history_entity.dart';
import 'application_note_entity.dart';

class ApplicationEntity extends Equatable {
  final int id;
  final int jobId;
  final int candidateId;
  final String? cvUrlSnapshot;
  final String? coverLetter;
  final String status;
  final String? rejectionReason;
  final String? employerNote;
  final double? matchScore;
  final String? matchReasoning;
  final double? cvMatchScore;
  final String? cvMatchReasoning;
  final DateTime appliedAt;
  final DateTime updatedAt;
  final JobPostEntity? job;
  final CandidateProfileEntity? candidate;
  final List<ApplicationStatusHistoryEntity>? statusHistory;
  final List<ApplicationNoteEntity>? notes;

  const ApplicationEntity({
    required this.id,
    required this.jobId,
    required this.candidateId,
    this.cvUrlSnapshot,
    this.coverLetter,
    required this.status,
    this.rejectionReason,
    this.employerNote,
    this.matchScore,
    this.matchReasoning,
    this.cvMatchScore,
    this.cvMatchReasoning,
    required this.appliedAt,
    required this.updatedAt,
    this.job,
    this.candidate,
    this.statusHistory,
    this.notes,
  });

  @override
  List<Object?> get props => [
        id,
        jobId,
        candidateId,
        cvUrlSnapshot,
        coverLetter,
        status,
        rejectionReason,
        employerNote,
        matchScore,
        matchReasoning,
        cvMatchScore,
        cvMatchReasoning,
        appliedAt,
        updatedAt,
        job,
        candidate,
        statusHistory,
        notes,
      ];
}
