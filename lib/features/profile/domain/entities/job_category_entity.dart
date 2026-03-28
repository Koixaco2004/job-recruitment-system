import 'package:equatable/equatable.dart';

class JobCategoryEntity extends Equatable {
  final int id;
  final String name;

  const JobCategoryEntity({
    required this.id,
    required this.name,
  });

  @override
  List<Object?> get props => [id, name];
}

class CandidateJobCategoryEntity extends Equatable {
  final int id; // Mapping record ID
  final int candidateId;
  final int jobCategoryId;
  final JobCategoryEntity? jobCategory;

  const CandidateJobCategoryEntity({
    required this.id,
    required this.candidateId,
    required this.jobCategoryId,
    this.jobCategory,
  });

  @override
  List<Object?> get props => [id, candidateId, jobCategoryId, jobCategory];
}
