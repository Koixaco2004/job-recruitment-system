import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/application_kanban_column_entity.dart';
import '../repositories/application_repository.dart';

class GetKanbanBoardUseCase {
  final ApplicationRepository repository;

  GetKanbanBoardUseCase(this.repository);

  Future<Either<Failure, List<ApplicationKanbanColumnEntity>>> call(int jobId) {
    return repository.getKanbanBoard(jobId);
  }
}
