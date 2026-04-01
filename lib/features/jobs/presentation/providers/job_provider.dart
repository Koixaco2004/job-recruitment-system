import 'package:flutter/material.dart';
import '../../domain/entities/job_post_entity.dart';
import '../../domain/models/job_filter_model.dart';
import '../../domain/usecases/get_jobs_usecase.dart';
import '../../domain/usecases/submit_application_usecase.dart';
import '../../domain/usecases/create_job_usecase.dart';
import '../../domain/usecases/update_job_usecase.dart';
import '../../domain/usecases/get_employer_jobs_usecase.dart';
import '../../domain/usecases/get_job_detail_usecase.dart';

/// Provider quản lý state cho Jobs
class JobProvider extends ChangeNotifier {
  final GetJobsUseCase getJobsUseCase;
  final SubmitApplicationUseCase submitApplicationUseCase;
  final CreateJobUseCase createJobUseCase;
  final UpdateJobUseCase updateJobUseCase;
  final GetEmployerJobsUseCase getEmployerJobsUseCase;
  final GetJobDetailUseCase getJobDetailUseCase;

  JobProvider({
    required this.getJobsUseCase,
    required this.submitApplicationUseCase,
    required this.createJobUseCase,
    required this.updateJobUseCase,
    required this.getEmployerJobsUseCase,
    required this.getJobDetailUseCase,
  });

  // State
  // State (Candidate Public Jobs)
  bool _isLoading = false;
  List<JobPostEntity> _allJobs = []; // List hiện tại
  int _totalPublicJobs = 0;
  int _currentPublicPage = 1;
  String? _errorMessage;
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

  // Job Management State
  bool _isSavingJob = false;
  bool _saveJobSuccess = false;
  String? _saveJobError;

  // Getters
  bool get isLoading => _isLoading;
  List<JobPostEntity> get jobs => _allJobs;
  List<JobPostEntity> get allJobs => _allJobs;
  int get totalPublicJobs => _totalPublicJobs;
  int get currentPublicPage => _currentPublicPage;
  String? get errorMessage => _errorMessage;
  bool get hasMoreJobs => _allJobs.length < _totalPublicJobs;
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
  bool get isSavingJob => _isSavingJob;
  bool get saveJobSuccess => _saveJobSuccess;
  String? get saveJobError => _saveJobError;

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
    _currentPublicPage = refresh ? 1 : _currentPublicPage;
    _totalPublicJobs = refresh ? 0 : _totalPublicJobs;
    if (refresh) {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();
    }

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
      (data) {
        _isLoading = false;
        final newJobs = data['jobs'] as List<JobPostEntity>;
        
        if (!refresh) {
          _allJobs.addAll(newJobs);
        } else {
          _allJobs = List.from(newJobs);
        }

        _totalPublicJobs = data['total'] as int;
        _currentPublicPage = data['currentPage'] as int;
        _errorMessage = null;
        notifyListeners();
      },
    );
  }

  /// Lấy chi tiết công việc
  Future<void> fetchJobDetail(int jobId) async {
    _isLoading = true;
    _currentJobDetail = null;
    _errorMessage = null;
    notifyListeners();

    final result = await getJobDetailUseCase(jobId);

    result.fold(
      (failure) {
        _isLoading = false;
        _errorMessage = failure.message;
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
      (data) {
        _isLoadingEmployerJobs = false;
        final jobs = data['jobs'] as List<JobPostEntity>;
        
        if (status == 'published') {
          _publishedEmployerJobs = jobs;
        } else if (status == 'draft') {
          _draftEmployerJobs = jobs;
        } else {
          _allEmployerJobs = jobs;
        }
        
        _totalEmployerJobs = data['total'] as int;
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
}
