import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/application_entity.dart';
import '../../domain/repositories/application_repository.dart';

class GetEmployerApplicationDetailUseCase {
  final ApplicationRepository repository;

  GetEmployerApplicationDetailUseCase(this.repository);

  Future<Either<Failure, ApplicationEntity>> call(int id) async {
    return await repository.getEmployerApplicationDetail(id);
  }
}
