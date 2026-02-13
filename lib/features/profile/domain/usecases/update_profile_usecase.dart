import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/candidate_profile_entity.dart';
import '../repositories/profile_repository.dart';

class UpdateProfileUseCase {
  final ProfileRepository repository;
  UpdateProfileUseCase(this.repository);

  Future<Either<Failure, CandidateProfileEntity>> call(
    CandidateProfileEntity profile,
  ) async {
    return await repository.updateProfile(profile);
  }
}
