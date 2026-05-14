import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../data/models/job_detailed_stats_model.dart';
import '../repositories/headhunting_repository.dart';

class GetJobDetailedStatsUseCase {
  final HeadhuntingRepository repository;

  GetJobDetailedStatsUseCase(this.repository);

  Future<Either<Failure, JobDetailedStatsModel>> call(
    int jobId, {
    int expiringSoonDays = 7,
    int? year,
    String? granularity,
    String? date,
    int? month,
    String? quarter,
  }) async {
    return await repository.getJobDetailedStats(
      jobId,
      expiringSoonDays: expiringSoonDays,
      year: year,
      granularity: granularity,
      date: date,
      month: month,
      quarter: quarter,
    );
  }
}
