import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/job_status_history_entity.dart';
import '../repositories/job_repository.dart';

class GetJobHistoryUseCase {
  final JobRepository repository;

  GetJobHistoryUseCase(this.repository);

  Future<Either<Failure, List<JobStatusHistoryEntity>>> call(int jobId) async {
    return await repository.getJobHistory(jobId);
  }
}
