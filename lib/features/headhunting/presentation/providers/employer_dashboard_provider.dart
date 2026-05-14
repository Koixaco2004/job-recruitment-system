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

  // Filter State
  int _currentYear = DateTime.now().year;
  int get currentYear => _currentYear;

  String _currentGranularity = 'month'; // 'day', 'month', 'quarter'
  String get currentGranularity => _currentGranularity;

  int _currentMonth = DateTime.now().month;
  int get currentMonth => _currentMonth;

  String _currentQuarter = 'Q1';
  String get currentQuarter => _currentQuarter;

  void setFilters({
    int? year,
    String? granularity,
    int? month,
    String? quarter,
  }) {
    if (year != null) _currentYear = year;
    if (granularity != null) _currentGranularity = granularity;
    if (month != null) _currentMonth = month;
    if (quarter != null) _currentQuarter = quarter;
    notifyListeners();
  }

  Future<void> fetchDashboardStats({int expiringSoonDays = 7}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final result = await getDashboardStatsUseCase(
      expiringSoonDays: expiringSoonDays,
      year: _currentYear,
      granularity: _currentGranularity,
      month: _currentGranularity == 'month' ? _currentMonth : null,
      quarter: _currentGranularity == 'quarter' ? _currentQuarter : null,
    );

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

    final result = await getJobDetailedStatsUseCase(
      jobId,
      year: _currentYear,
      granularity: _currentGranularity,
      month: _currentGranularity == 'month' ? _currentMonth : null,
      quarter: _currentGranularity == 'quarter' ? _currentQuarter : null,
    );

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
