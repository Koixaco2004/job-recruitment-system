import '../../domain/entities/suggested_candidates_response_entity.dart';
import 'headhunting_candidate_model.dart';

class SuggestedCandidatesResponseModel extends SuggestedCandidatesResponseEntity {
  const SuggestedCandidatesResponseModel({
    required super.data,
    required super.total,
    required super.page,
    required super.lastPage,
    required super.appliedWeights,
  });

  factory SuggestedCandidatesResponseModel.fromJson(Map<String, dynamic> json) {
    return SuggestedCandidatesResponseModel(
      data: (json['data'] as List<dynamic>?)
              ?.map((e) => HeadhuntingCandidateModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      total: json['total'] as int? ?? 0,
      page: json['page'] as int? ?? 1,
      lastPage: json['lastPage'] as int? ?? 1,
      appliedWeights: AppliedWeightsModel.fromJson(
          json['appliedWeights'] as Map<String, dynamic>? ?? {}),
    );
  }
}

class AppliedWeightsModel extends AppliedWeightsEntity {
  const AppliedWeightsModel({
    required super.skillWeight,
    required super.levelWeight,
    required super.experienceWeight,
    required super.salaryWeight,
    required super.degreeWeight,
    required super.locationWeight,
    required super.profileWeight,
  });

  factory AppliedWeightsModel.fromJson(Map<String, dynamic> json) {
    return AppliedWeightsModel(
      skillWeight: json['skillWeight'] as int? ?? 0,
      levelWeight: json['levelWeight'] as int? ?? 0,
      experienceWeight: json['experienceWeight'] as int? ?? 0,
      salaryWeight: json['salaryWeight'] as int? ?? 0,
      degreeWeight: json['degreeWeight'] as int? ?? 0,
      locationWeight: json['locationWeight'] as int? ?? 0,
      profileWeight: json['profileWeight'] as int? ?? 0,
    );
  }
}
