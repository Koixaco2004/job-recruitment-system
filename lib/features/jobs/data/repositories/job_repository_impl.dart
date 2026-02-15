import 'package:dartz/dartz.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/application_entity.dart';
import '../../domain/entities/job_post_entity.dart';
import '../../domain/entities/saved_job_entity.dart';
import '../../domain/repositories/job_repository.dart';
import '../datasources/job_remote_datasource.dart';

/// Concrete implementation của JobRepository
class JobRepositoryImpl implements JobRepository {
  final JobRemoteDataSource remoteDataSource;

  JobRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<JobPostEntity>>> getJobs() async {
    try {
      final jobs = await remoteDataSource.getJobs();
      return Right(jobs);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Đã xảy ra lỗi: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, JobPostEntity>> getJobById(int jobId) async {
    try {
      final job = await remoteDataSource.getJobById(jobId);
      return Right(job);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Đã xảy ra lỗi: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<JobPostEntity>>> searchJobs(
    String keyword,
  ) async {
    try {
      final jobs = await remoteDataSource.getJobs();
      final filteredJobs = jobs
          .where(
            (job) =>
                job.title.toLowerCase().contains(keyword.toLowerCase()) ||
                job.companyName.toLowerCase().contains(keyword.toLowerCase()),
          )
          .toList();
      return Right(filteredJobs);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Đã xảy ra lỗi: ${e.toString()}'));
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
}
