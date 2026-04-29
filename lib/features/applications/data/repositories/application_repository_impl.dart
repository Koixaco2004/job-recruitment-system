import 'package:dartz/dartz.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/models/paginated_response.dart';
import '../../domain/entities/application_entity.dart';
import '../../domain/repositories/application_repository.dart';
import '../datasources/application_remote_datasource.dart';
import '../datasources/employer_application_remote_datasource.dart';
import '../../domain/entities/application_kanban_column_entity.dart';
import '../../domain/entities/application_status_history_entity.dart';
import '../../domain/entities/application_note_entity.dart';

class ApplicationRepositoryImpl implements ApplicationRepository {
  final ApplicationRemoteDataSource remoteDataSource;
  final EmployerApplicationRemoteDataSource employerRemoteDataSource;

  ApplicationRepositoryImpl({
    required this.remoteDataSource,
    required this.employerRemoteDataSource,
  });

  @override
  Future<Either<Failure, ApplicationEntity>> apply({
    required int jobId,
    String? coverLetter,
  }) async {
    try {
      final result = await remoteDataSource.apply(
        jobId: jobId,
        coverLetter: coverLetter,
      );
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, PaginatedResponse<ApplicationEntity>>> getMyApplications({
    int page = 1,
    int limit = 10,
    String? status,
  }) async {
    try {
      final result = await remoteDataSource.getMyApplications(
        page: page,
        limit: limit,
        status: status,
      );
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, ApplicationEntity>> getApplicationDetail(int id) async {
    try {
      final result = await remoteDataSource.getApplicationDetail(id);
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> withdrawApplication(int id) async {
    try {
      await remoteDataSource.withdrawApplication(id);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, PaginatedResponse<ApplicationEntity>>> getJobApplications(
    int jobId, {
    int page = 1,
    int limit = 10,
    String? status,
  }) async {
    try {
      final result = await employerRemoteDataSource.getJobApplications(
        jobId,
        page: page,
        limit: limit,
        status: status,
      );
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<ApplicationKanbanColumnEntity>>> getKanbanBoard(
    int jobId,
  ) async {
    try {
      final result = await employerRemoteDataSource.getKanbanBoard(jobId);
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, ApplicationEntity>> getEmployerApplicationDetail(
    int id,
  ) async {
    try {
      final result = await employerRemoteDataSource.getEmployerApplicationDetail(id);
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<ApplicationStatusHistoryEntity>>> getApplicationHistory(int id) async {
    try {
      final history = await employerRemoteDataSource.getApplicationHistory(id);
      return Right(history);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> updateApplicationStatus(
    int id,
    String status, {
    String? reason,
    String? note,
  }) async {
    try {
      await employerRemoteDataSource.updateApplicationStatus(
        id,
        status,
        reason: reason,
        note: note,
      );
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, ApplicationNoteEntity>> addApplicationNote({
    required int applicationId,
    required String content,
  }) async {
    try {
      final result = await employerRemoteDataSource.addNote(applicationId, content);
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, ApplicationNoteEntity>> updateApplicationNote({
    required int noteId,
    required String content,
  }) async {
    try {
      final result = await employerRemoteDataSource.updateNote(noteId, content);
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, ApplicationEntity>> analyzeAi(int id) async {
    try {
      final result = await employerRemoteDataSource.analyzeAi(id);
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
