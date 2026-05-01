import 'package:flutter/material.dart';
import '../../domain/entities/job_post_entity.dart';
import '../../domain/usecases/get_recommended_jobs_usecase.dart';

class RecommendedJobsProvider extends ChangeNotifier {
  final GetRecommendedJobsUseCase getRecommendedJobsUseCase;

  RecommendedJobsProvider({required this.getRecommendedJobsUseCase});

  List<JobPostEntity> _recommendedJobs = [];
  bool _isLoading = false;
  String? _errorMessage;
  int _currentPage = 1;
  bool _hasMore = true;
  int _totalJobs = 0;

  List<JobPostEntity> get recommendedJobs => _recommendedJobs;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get hasMore => _hasMore;
  int get totalJobs => _totalJobs;

  Future<void> fetchRecommendedJobs({bool refresh = false}) async {
    if (refresh) {
      _currentPage = 1;
      _recommendedJobs = [];
      _hasMore = true;
    }

    if (!_hasMore || _isLoading) return;

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final result = await getRecommendedJobsUseCase(
      page: _currentPage,
      limit: 20,
    );

    result.fold(
      (failure) {
        _errorMessage = failure.message;
        _isLoading = false;
        notifyListeners();
      },
      (paginatedResponse) {
        _recommendedJobs.addAll(paginatedResponse.data);
        _totalJobs = paginatedResponse.total;
        _hasMore = _currentPage < paginatedResponse.lastPage;
        if (_hasMore) {
          _currentPage++;
        }
        _isLoading = false;
        notifyListeners();
      },
    );
  }
}
