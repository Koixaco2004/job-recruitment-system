import 'package:flutter/material.dart';
import '../../data/models/employer_dashboard_stats_model.dart';
import '../../data/models/job_detailed_stats_model.dart';
import '../../domain/usecases/get_dashboard_stats_usecase.dart';
import '../../domain/usecases/get_job_detailed_stats_usecase.dart';

class EmployerDashboardProvider extends ChangeNotifier {
  final GetDashboardStatsUseCase getDashboardStatsUseCase;
  final GetJobDetailedStatsUseCase getJobDetailedStatsUseCase;

  EmployerDashboardProvider({
    required this.getDashboardStatsUseCase,
    required this.getJobDetailedStatsUseCase,
  });

  EmployerDashboardStatsModel? _stats;
  EmployerDashboardStatsModel? get stats => _stats;

  JobDetailedStatsModel? _jobStats;
  JobDetailedStatsModel? get jobStats => _jobStats;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  Future<void> fetchDashboardStats({int expiringSoonDays = 7}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final result = await getDashboardStatsUseCase(expiringSoonDays: expiringSoonDays);

    result.fold(
      (failure) {
        _errorMessage = failure.message;
        _isLoading = false;
        notifyListeners();
      },
      (data) {
        _stats = data;
        _isLoading = false;
        notifyListeners();
      },
    );
  }

  Future<void> fetchJobDetailedStats(int jobId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final result = await getJobDetailedStatsUseCase(jobId);

    result.fold(
      (failure) {
        _errorMessage = failure.message;
        _isLoading = false;
        notifyListeners();
      },
      (data) {
        _jobStats = data;
        _isLoading = false;
        notifyListeners();
      },
    );
  }

  void clearJobStats() {
    _jobStats = null;
    notifyListeners();
  }
}
