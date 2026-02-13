import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/candidate_profile_entity.dart';
import '../repositories/profile_repository.dart';

class GetProfileUseCase {
  final ProfileRepository repository;
  GetProfileUseCase(this.repository);

  Future<Either<Failure, CandidateProfileEntity>> call() async {
    return await repository.getProfile();
  }
}
