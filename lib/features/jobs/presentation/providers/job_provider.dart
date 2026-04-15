import 'package:flutter/material.dart';
import '../../domain/entities/job_post_entity.dart';
import '../../domain/models/job_filter_model.dart';
import '../../domain/usecases/get_jobs_usecase.dart';
import '../../domain/usecases/submit_application_usecase.dart';
import '../../domain/usecases/create_job_usecase.dart';
import '../../domain/usecases/update_job_usecase.dart';
import '../../domain/usecases/get_employer_jobs_usecase.dart';
import '../../domain/usecases/get_job_detail_usecase.dart';
import '../../domain/usecases/get_job_history_usecase.dart';
import '../../domain/entities/job_status_history_entity.dart';

/// Provider quản lý state cho Jobs
class JobProvider extends ChangeNotifier {
  final GetJobsUseCase getJobsUseCase;
  final SubmitApplicationUseCase submitApplicationUseCase;
  final CreateJobUseCase createJobUseCase;
  final UpdateJobUseCase updateJobUseCase;
  final GetEmployerJobsUseCase getEmployerJobsUseCase;
  final GetJobDetailUseCase getJobDetailUseCase;
  final GetJobHistoryUseCase getJobHistoryUseCase;

  JobProvider({
    required this.getJobsUseCase,
    required this.submitApplicationUseCase,
    required this.createJobUseCase,
    required this.updateJobUseCase,
    required this.getEmployerJobsUseCase,
    required this.getJobDetailUseCase,
    required this.getJobHistoryUseCase,
  });

  // State
  // State (Candidate Public Jobs)
  bool _isLoading = false;
  List<JobPostEntity> _allJobs = []; // List hiện tại
  int _totalPublicJobs = 0;
  int _currentPublicPage = 1;
  int _lastPublicPage = 1;
  String? _errorMessage;
  String? _jobDetailError;
  JobFilterModel _filter = const JobFilterModel();
  JobPostEntity? _currentJobDetail;

  // Apply state
  bool _isApplying = false;
  bool _applySuccess = false;
  String? _applyError;

  // Employer State
  List<JobPostEntity> _allEmployerJobs = [];
  List<JobPostEntity> _publishedEmployerJobs = [];
  List<JobPostEntity> _draftEmployerJobs = [];
  bool _isLoadingEmployerJobs = false;
  int _totalEmployerJobs = 0;
  int _currentEmployerPage = 1;
  int _lastEmployerPage = 1;

  // Job Management State
  bool _isSavingJob = false;
  bool _saveJobSuccess = false;
  String? _saveJobError;

  // History State
  List<JobStatusHistoryEntity> _jobHistory = [];
  bool _isLoadingHistory = false;

  // Getters
  bool get isLoading => _isLoading;
  List<JobPostEntity> get jobs => _allJobs;
  List<JobPostEntity> get allJobs => _allJobs;
  int get totalPublicJobs => _totalPublicJobs;
  int get currentPublicPage => _currentPublicPage;
  int get lastPublicPage => _lastPublicPage;
  String? get errorMessage => _errorMessage;
  String? get jobDetailError => _jobDetailError;
  bool get hasMoreJobs => _currentPublicPage < _lastPublicPage;
  bool get hasJobs => _allJobs.isNotEmpty;
  JobFilterModel get filter => _filter;
  JobPostEntity? get currentJobDetail => _currentJobDetail;
  bool get isApplying => _isApplying;
  bool get applySuccess => _applySuccess;
  String? get applyError => _applyError;

  // Employer Getters
  List<JobPostEntity> get employerJobs => _allEmployerJobs;
  List<JobPostEntity> get publishedJobs => _publishedEmployerJobs;
  List<JobPostEntity> get draftJobs => _draftEmployerJobs;
  
  List<JobPostEntity> getEmployerJobsByStatus(String? status) {
    if (status == 'published') return _publishedEmployerJobs;
    if (status == 'draft') return _draftEmployerJobs;
    return _allEmployerJobs;
  }

  bool get isLoadingEmployerJobs => _isLoadingEmployerJobs;
  int get totalEmployerJobs => _totalEmployerJobs;
  int get currentEmployerPage => _currentEmployerPage;
  int get lastEmployerPage => _lastEmployerPage;
  bool get hasMoreEmployerJobs => _currentEmployerPage < _lastEmployerPage;
  bool get isSavingJob => _isSavingJob;
  bool get saveJobSuccess => _saveJobSuccess;
  String? get saveJobError => _saveJobError;
  
  List<JobStatusHistoryEntity> get jobHistory => _jobHistory;
  bool get isLoadingHistory => _isLoadingHistory;

  /// Fetch jobs (Public API)
  Future<void> fetchJobs({bool refresh = true}) async {
    await fetchPublicJobs(
      page: refresh ? 1 : _currentPublicPage + 1,
      refresh: refresh,
    );
  }

  /// Fetch public jobs with filters and pagination
  Future<void> fetchPublicJobs({
    int page = 1,
    int limit = 10,
    bool refresh = true,
    String? keyword,
    int? provinceId,
    int? categoryId,
    int? jobTypeId,
  }) async {
    if (_isLoading) return; // Chặn yêu cầu nếu đang thực hiện
    
    _isLoading = true;
    _errorMessage = null;
    
    if (refresh) {
      _currentPublicPage = 1;
      _totalPublicJobs = 0;
    }
    notifyListeners();

    final result = await getJobsUseCase(
      page: refresh ? 1 : page,
      limit: limit,
      keyword: keyword ?? _filter.keyword,
      provinceId: provinceId ?? _filter.provinceId, 
      categoryId: categoryId ?? _filter.categoryId,
      jobTypeId: jobTypeId ?? _filter.jobTypeId,
    );

    result.fold(
      (failure) {
        _isLoading = false;
        _errorMessage = failure.message;
        notifyListeners();
      },
      (paginatedResponse) {
        _isLoading = false;
        final newJobs = paginatedResponse.data;
        
        if (refresh) {
          _allJobs = List.from(newJobs);
        } else {
          // Tránh trùng lặp ID khi addAll
          final existingIds = _allJobs.map((j) => j.jobPostId).toSet();
          final uniqueNewJobs = newJobs.where((j) => !existingIds.contains(j.jobPostId)).toList();
          _allJobs.addAll(uniqueNewJobs);
        }

        _totalPublicJobs = paginatedResponse.total;
        _currentPublicPage = paginatedResponse.page;
        _lastPublicPage = paginatedResponse.lastPage;
        _errorMessage = null;
        notifyListeners();
      },
    );
  }

  /// Lấy chi tiết công việc
  Future<void> fetchJobDetail(int jobId) async {
    _isLoading = true;
    _currentJobDetail = null;
    _jobDetailError = null; // Clear detail error
    notifyListeners();

    final result = await getJobDetailUseCase(jobId);

    result.fold(
      (failure) {
        _isLoading = false;
        _jobDetailError = failure.message; // Use detail error variable
        notifyListeners();
      },
      (job) {
        _isLoading = false;
        _currentJobDetail = job;
        notifyListeners();
      },
    );
  }

  /// Update filter and apply
  void updateFilter(JobFilterModel newFilter) {
    _filter = newFilter;
    fetchPublicJobs(refresh: true); // Re-fetch from API with new filter
    notifyListeners();
  }

  /// Clear all filters
  void clearFilter() {
    _filter = const JobFilterModel();
    fetchPublicJobs(refresh: true);
    notifyListeners();
  }

  /// Gửi đơn ứng tuyển
  Future<bool> submitApplication({
    required int jobPostId,
    required int candidateId,
    String? cvFileUrl,
    String? coverLetter,
  }) async {
    _isApplying = true;
    _applySuccess = false;
    _applyError = null;
    notifyListeners();

    final result = await submitApplicationUseCase(
      jobPostId: jobPostId,
      candidateId: candidateId,
      cvFileUrl: cvFileUrl,
      coverLetter: coverLetter,
    );

    return result.fold(
      (failure) {
        _isApplying = false;
        _applyError = failure.message;
        notifyListeners();
        return false;
      },
      (application) {
        _isApplying = false;
        _applySuccess = true;
        notifyListeners();
        return true;
      },
    );
  }

  /// Clear apply state
  void clearApplyState() {
    _applySuccess = false;
    _applyError = null;
    notifyListeners();
  }

  /// Clear error message
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  /// Clear job detail error message
  void clearJobDetailError() {
    _jobDetailError = null;
    notifyListeners();
  }

  // --- Employer Job Management Methods ---

  Future<void> fetchEmployerJobs({int page = 1, String? status}) async {
    _isLoadingEmployerJobs = true;
    _errorMessage = null;
    notifyListeners();

    final result = await getEmployerJobsUseCase(
      page: page,
      status: status,
    );

    result.fold(
      (failure) {
        _isLoadingEmployerJobs = false;
        _errorMessage = failure.message;
        notifyListeners();
      },
      (paginatedResponse) {
        _isLoadingEmployerJobs = false;
        final jobs = paginatedResponse.data;
        
        if (status == 'published') {
          if (page == 1) {
            _publishedEmployerJobs = List.from(jobs);
          } else {
            _publishedEmployerJobs.addAll(jobs);
          }
        } else if (status == 'draft') {
          if (page == 1) {
            _draftEmployerJobs = List.from(jobs);
          } else {
            _draftEmployerJobs.addAll(jobs);
          }
        } else {
          if (page == 1) {
            _allEmployerJobs = List.from(jobs);
          } else {
            _allEmployerJobs.addAll(jobs);
          }
        }
        
        _totalEmployerJobs = paginatedResponse.total;
        _currentEmployerPage = paginatedResponse.page;
        _lastEmployerPage = paginatedResponse.lastPage;
        notifyListeners();
      },
    );
  }

  Future<JobPostEntity?> createJob(Map<String, dynamic> data) async {
    _isSavingJob = true;
    _saveJobSuccess = false;
    _saveJobError = null;
    notifyListeners();

    final result = await createJobUseCase(data);

    return result.fold(
      (failure) {
        _isSavingJob = false;
        _saveJobError = failure.message;
        notifyListeners();
        return null;
      },
      (job) {
        _isSavingJob = false;
        _saveJobSuccess = true;
        fetchEmployerJobs(); // Refresh list
        notifyListeners();
        return job;
      },
    );
  }

  Future<bool> publishJob(int jobId) async {
    return updateJob(jobId, {'status': 'published'});
  }

  Future<bool> updateJob(int jobId, Map<String, dynamic> data) async {
    _isSavingJob = true;
    _saveJobSuccess = false;
    _saveJobError = null;
    notifyListeners();

    final result = await updateJobUseCase(jobId, data);

    return result.fold(
      (failure) {
        _isSavingJob = false;
        _saveJobError = failure.message;
        notifyListeners();
        return false;
      },
      (job) {
        _isSavingJob = false;
        _saveJobSuccess = true;
        fetchEmployerJobs(); // Refresh list
        notifyListeners();
        return true;
      },
    );
  }

  void resetSaveJobState() {
    _saveJobSuccess = false;
    _saveJobError = null;
    notifyListeners();
  }

  /// Lấy lịch sử thay đổi trạng thái
  Future<void> fetchJobHistory(int jobId) async {
    _isLoadingHistory = true;
    _jobHistory = [];
    _errorMessage = null;
    notifyListeners();

    final result = await getJobHistoryUseCase(jobId);

    result.fold(
      (failure) {
        _isLoadingHistory = false;
        _errorMessage = failure.message;
        notifyListeners();
      },
      (history) {
        _isLoadingHistory = false;
        _jobHistory = history;
        notifyListeners();
      },
    );
  }
}
