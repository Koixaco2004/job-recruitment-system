import 'package:equatable/equatable.dart';
import 'headhunting_candidate_entity.dart';

class SuggestedCandidatesResponseEntity extends Equatable {
  final List<HeadhuntingCandidateEntity> data;
  final int total;
  final int page;
  final int lastPage;
  final AppliedWeightsEntity appliedWeights;

  const SuggestedCandidatesResponseEntity({
    required this.data,
    required this.total,
    required this.page,
    required this.lastPage,
    required this.appliedWeights,
  });

  @override
  List<Object?> get props => [data, total, page, lastPage, appliedWeights];
}

class AppliedWeightsEntity extends Equatable {
  final int skillWeight;
  final int levelWeight;
  final int experienceWeight;
  final int salaryWeight;
  final int degreeWeight;
  final int locationWeight;
  final int profileWeight;

  const AppliedWeightsEntity({
    required this.skillWeight,
    required this.levelWeight,
    required this.experienceWeight,
    required this.salaryWeight,
    required this.degreeWeight,
    required this.locationWeight,
    required this.profileWeight,
  });

  @override
  List<Object?> get props => [
        skillWeight,
        levelWeight,
        experienceWeight,
        salaryWeight,
        degreeWeight,
        locationWeight,
        profileWeight,
      ];
}
