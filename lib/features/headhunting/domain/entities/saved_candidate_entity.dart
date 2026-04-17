import 'package:equatable/equatable.dart';
import 'headhunting_candidate_entity.dart';

class SavedCandidateEntity extends Equatable {
  final int id;
  final int employerId;
  final int candidateId;
  final String? note;
  final DateTime createdAt;
  final HeadhuntingCandidateEntity? candidate;

  const SavedCandidateEntity({
    required this.id,
    required this.employerId,
    required this.candidateId,
    this.note,
    required this.createdAt,
    this.candidate,
  });

  @override
  List<Object?> get props => [
        id,
        employerId,
        candidateId,
        note,
        createdAt,
        candidate,
      ];
}
