import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/models/paginated_response.dart';
import '../entities/application_entity.dart';
import '../entities/application_kanban_column_entity.dart';
import '../entities/application_status_history_entity.dart';
import '../entities/application_note_entity.dart';

abstract class ApplicationRepository {
  Future<Either<Failure, ApplicationEntity>> apply({
    required int jobId,
    String? coverLetter,
  });

  Future<Either<Failure, PaginatedResponse<ApplicationEntity>>> getMyApplications({
    int page = 1,
    int limit = 10,
    String? status,
  });

  Future<Either<Failure, ApplicationEntity>> getApplicationDetail(int id);

  Future<Either<Failure, void>> withdrawApplication(int id);

  // Employer methods
  Future<Either<Failure, PaginatedResponse<ApplicationEntity>>> getJobApplications(
    int jobId, {
    int page = 1,
    int limit = 10,
    String? status,
  });

  Future<Either<Failure, List<ApplicationKanbanColumnEntity>>> getKanbanBoard(int jobId);

  Future<Either<Failure, ApplicationEntity>> getEmployerApplicationDetail(int id);

  Future<Either<Failure, List<ApplicationStatusHistoryEntity>>> getApplicationHistory(int id);

  Future<Either<Failure, void>> updateApplicationStatus(
    int id,
    String status, {
    String? reason,
    String? note,
  });

  Future<Either<Failure, ApplicationNoteEntity>> addApplicationNote({
    required int applicationId,
    required String content,
  });

  Future<Either<Failure, ApplicationNoteEntity>> updateApplicationNote({
    required int noteId,
    required String content,
  });
}
