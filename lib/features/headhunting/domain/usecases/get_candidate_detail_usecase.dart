import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/candidate_detail_entity.dart';
import '../repositories/headhunting_repository.dart';

class GetCandidateDetailUseCase {
  final HeadhuntingRepository repository;

  GetCandidateDetailUseCase(this.repository);

  Future<Either<Failure, CandidateDetailEntity>> call(int id) async {
    return await repository.getCandidateDetail(id);
  }
}
