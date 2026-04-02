import 'package:dartz/dartz.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/application_entity.dart';
import '../../domain/entities/job_post_entity.dart';
import '../../domain/entities/saved_job_entity.dart';
import '../../domain/entities/job_status_history_entity.dart';
import '../../domain/repositories/job_repository.dart';
import '../../../../core/models/paginated_response.dart';
import '../datasources/job_remote_datasource.dart';

/// Concrete implementation của JobRepository
class JobRepositoryImpl implements JobRepository {
  final JobRemoteDataSource remoteDataSource;

  JobRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, PaginatedResponse<JobPostEntity>>> getJobs({
    int page = 1,
    int limit = 10,
    String? keyword,
    int? provinceId,
    int? categoryId,
    int? jobTypeId,
  }) async {
    try {
      final result = await remoteDataSource.getJobs(
        page: page,
        limit: limit,
        keyword: keyword,
        provinceId: provinceId,
        categoryId: categoryId,
        jobTypeId: jobTypeId,
      );
      // Map model to entity (PaginatedResponse is covariant on data)
      return Right(PaginatedResponse<JobPostEntity>(
        data: result.data,
        total: result.total,
        page: result.page,
        lastPage: result.lastPage,
      ));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, JobPostEntity>> getJobById(int jobId) async {
    try {
      final remoteJob = await remoteDataSource.getJobById(jobId);
      return Right(remoteJob);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<JobPostEntity>>> searchJobs(
    String keyword,
  ) async {
    try {
      final result = await remoteDataSource.getJobs(keyword: keyword, limit: 50);
      return Right(result.data);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, ApplicationEntity>> submitApplication({
    required int jobPostId,
    required int candidateId,
    String? cvFileUrl,
    String? coverLetter,
  }) async {
    try {
      final application = await remoteDataSource.submitApplication(
        jobPostId: jobPostId,
        candidateId: candidateId,
        cvFileUrl: cvFileUrl,
        coverLetter: coverLetter,
      );
      return Right(application);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(
        ServerFailure('Không thể gửi đơn ứng tuyển: ${e.toString()}'),
      );
    }
  }

  @override
  Future<Either<Failure, List<SavedJobEntity>>> getSavedJobs(
    int candidateId,
  ) async {
    try {
      final savedJobs = await remoteDataSource.getSavedJobs(candidateId);
      return Right(savedJobs);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(
        ServerFailure('Không thể lấy danh sách việc đã lưu: ${e.toString()}'),
      );
    }
  }

  @override
  Future<Either<Failure, SavedJobEntity>> saveJob({
    required int candidateId,
    required int jobPostId,
  }) async {
    try {
      final savedJob = await remoteDataSource.saveJob(
        candidateId: candidateId,
        jobPostId: jobPostId,
      );
      return Right(savedJob);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Không thể lưu việc làm: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> unsaveJob(int savedJobId) async {
    try {
      await remoteDataSource.unsaveJob(savedJobId);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Không thể bỏ lưu việc làm: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> unsaveJobByJobPostId({
    required int candidateId,
    required int jobPostId,
  }) async {
    try {
      await remoteDataSource.unsaveJobByJobPostId(
        candidateId: candidateId,
        jobPostId: jobPostId,
      );
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Không thể bỏ lưu việc làm: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<ApplicationEntity>>> getMyApplications(
    int candidateId,
  ) async {
    try {
      final applications = await remoteDataSource.getMyApplications(
        candidateId,
      );
      return Right(applications);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(
        ServerFailure('Không thể lấy danh sách đơn ứng tuyển: ${e.toString()}'),
      );
    }
  }

  @override
  Future<Either<Failure, bool>> isJobSaved({
    required int candidateId,
    required int jobPostId,
  }) async {
    try {
      final isSaved = await remoteDataSource.isJobSaved(
        candidateId: candidateId,
        jobPostId: jobPostId,
      );
      return Right(isSaved);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(
        ServerFailure('Không thể kiểm tra trạng thái lưu: ${e.toString()}'),
      );
    }
  }

  // --- Employer - Job Management ---

  @override
  Future<Either<Failure, JobPostEntity>> createJob(
    Map<String, dynamic> data,
  ) async {
    try {
      final job = await remoteDataSource.createJob(data);
      return Right(job);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Không thể tạo tin tuyển dụng: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, JobPostEntity>> updateJob(
    int jobId,
    Map<String, dynamic> data,
  ) async {
    try {
      final job = await remoteDataSource.updateJob(jobId, data);
      return Right(job);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(
        ServerFailure('Không thể cập nhật tin tuyển dụng: ${e.toString()}'),
      );
    }
  }

  @override
  Future<Either<Failure, PaginatedResponse<JobPostEntity>>> getMyJobsForEmployer({
    int page = 1,
    int limit = 10,
    String? status,
  }) async {
    try {
      final result = await remoteDataSource.getMyJobsForEmployer(
        page: page,
        limit: limit,
        status: status,
      );
      return Right(PaginatedResponse<JobPostEntity>(
        data: result.data,
        total: result.total,
        page: result.page,
        lastPage: result.lastPage,
      ));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(
        ServerFailure('Không thể lấy danh sách tin tuyển dụng: ${e.toString()}'),
      );
    }
  }

  @override
  Future<Either<Failure, List<JobStatusHistoryEntity>>> getJobHistory(int jobId) async {
    try {
      final history = await remoteDataSource.getJobHistory(jobId);
      return Right(history);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(
        ServerFailure('Không thể lấy lịch sử tin tuyển dụng: ${e.toString()}'),
      );
    }
  }
}
