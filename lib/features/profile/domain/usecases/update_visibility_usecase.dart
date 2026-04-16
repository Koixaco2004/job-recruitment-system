import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../repositories/profile_repository.dart';

class UpdateVisibilityUseCase {
  final ProfileRepository repository;

  UpdateVisibilityUseCase(this.repository);

  Future<Either<Failure, void>> call(bool isVisible) async {
    return await repository.updateVisibility(isVisible);
  }
}
