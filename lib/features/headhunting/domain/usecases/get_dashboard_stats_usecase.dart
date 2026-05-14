import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../data/models/employer_dashboard_stats_model.dart';
import '../repositories/headhunting_repository.dart';

class GetDashboardStatsUseCase {
  final HeadhuntingRepository repository;

  GetDashboardStatsUseCase(this.repository);

  Future<Either<Failure, EmployerDashboardStatsModel>> call({
    int expiringSoonDays = 7,
    int? year,
    String? granularity,
    String? date,
    int? month,
    String? quarter,
  }) async {
    return await repository.getDashboardStats(
      expiringSoonDays: expiringSoonDays,
      year: year,
      granularity: granularity,
      date: date,
      month: month,
      quarter: quarter,
    );
  }
}
