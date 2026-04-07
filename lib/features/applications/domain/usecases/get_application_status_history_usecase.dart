import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/application_status_history_entity.dart';
import '../repositories/application_repository.dart';

class GetApplicationStatusHistoryUseCase {
  final ApplicationRepository repository;

  GetApplicationStatusHistoryUseCase(this.repository);

  Future<Either<Failure, List<ApplicationStatusHistoryEntity>>> call(int id) async {
    return await repository.getApplicationHistory(id);
  }
}
