import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../repositories/headhunting_repository.dart';

class SearchCandidatesUseCase {
  final HeadhuntingRepository repository;

  SearchCandidatesUseCase(this.repository);

  Future<Either<Failure, Map<String, dynamic>>> call({
    String? keyword,
    int? provinceId,
    int? minExperience,
    List<int>? categoryIds,
    List<int>? skillIds,
    int? jobTypeId,
    int? salaryMin,
    int? salaryMax,
    String? requiredDegree,
    int? jobId,
    String? sortBy,
    String? sortOrder,
    Map<String, int>? scoring,
    int page = 1,
  }) {
    return repository.searchCandidates(
      keyword: keyword,
      provinceId: provinceId,
      minExperience: minExperience,
      categoryIds: categoryIds,
      skillIds: skillIds,
      jobTypeId: jobTypeId,
      salaryMin: salaryMin,
      salaryMax: salaryMax,
      requiredDegree: requiredDegree,
      jobId: jobId,
      sortBy: sortBy,
      sortOrder: sortOrder,
      scoring: scoring,
      page: page,
    );
  }
}
