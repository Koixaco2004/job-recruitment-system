import '../../domain/entities/saved_candidate_entity.dart';
import 'headhunting_candidate_model.dart';

class SavedCandidateModel extends SavedCandidateEntity {
  const SavedCandidateModel({
    required super.id,
    required super.employerId,
    required super.candidateId,
    super.note,
    required super.createdAt,
    super.candidate,
  });

  factory SavedCandidateModel.fromJson(Map<String, dynamic> json) {
    return SavedCandidateModel(
      id: json['id'] as int,
      employerId: json['employerId'] as int,
      candidateId: json['candidateId'] as int,
      note: json['note'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      candidate: json['candidate'] != null
          ? HeadhuntingCandidateModel.fromJson(json['candidate'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'employerId': employerId,
      'candidateId': candidateId,
      'note': note,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
