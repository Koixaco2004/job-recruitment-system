import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../repositories/headhunting_repository.dart';

class SearchCandidatesUseCase {
  final HeadhuntingRepository repository;

  SearchCandidatesUseCase(this.repository);

  Future<Either<Failure, Map<String, dynamic>>> call({
    String? keyword,
    int? provinceId,
    int? yearsOfExperience,
    int? jobCategoryId,
    int? jobTypeId,
    int page = 1,
  }) {
    return repository.searchCandidates(
      keyword: keyword,
      provinceId: provinceId,
      yearsOfExperience: yearsOfExperience,
      jobCategoryId: jobCategoryId,
      jobTypeId: jobTypeId,
      page: page,
    );
  }
}
