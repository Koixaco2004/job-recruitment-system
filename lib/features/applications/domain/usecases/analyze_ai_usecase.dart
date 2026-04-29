import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/application_entity.dart';
import '../repositories/application_repository.dart';

class AnalyzeAiUseCase {
  final ApplicationRepository repository;

  AnalyzeAiUseCase(this.repository);

  Future<Either<Failure, ApplicationEntity>> call(int id) async {
    return await repository.analyzeAi(id);
  }
}
