import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../repositories/application_repository.dart';

class UpdateApplicationStatusUseCase {
  final ApplicationRepository repository;

  UpdateApplicationStatusUseCase(this.repository);

  Future<Either<Failure, void>> call({
    required int id,
    required String status,
    String? reason,
    String? note,
  }) async {
    return await repository.updateApplicationStatus(
      id,
      status,
      reason: reason,
      note: note,
    );
  }
}
