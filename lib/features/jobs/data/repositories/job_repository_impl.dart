import 'package:dartz/dartz.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/application_entity.dart';
import '../../domain/entities/job_post_entity.dart';
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
}
