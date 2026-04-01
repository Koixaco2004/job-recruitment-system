import 'package:flutter/material.dart';
import '../../domain/entities/job_post_entity.dart';
import '../../domain/models/job_filter_model.dart';
import '../../domain/usecases/get_jobs_usecase.dart';
import '../../domain/usecases/submit_application_usecase.dart';
import '../../domain/usecases/create_job_usecase.dart';
import '../../domain/usecases/update_job_usecase.dart';
import '../../domain/usecases/get_employer_jobs_usecase.dart';

/// Provider quản lý state cho Jobs
class JobProvider extends ChangeNotifier {
  final GetJobsUseCase getJobsUseCase;
  final SubmitApplicationUseCase submitApplicationUseCase;
  final CreateJobUseCase createJobUseCase;
  final UpdateJobUseCase updateJobUseCase;
  final GetEmployerJobsUseCase getEmployerJobsUseCase;

  JobProvider({
    required this.getJobsUseCase,
    required this.submitApplicationUseCase,
    required this.createJobUseCase,
    required this.updateJobUseCase,
    required this.getEmployerJobsUseCase,
  });

  // State
  bool _isLoading = false;
  List<JobPostEntity> _allJobs = []; // Tất cả jobs từ API
  List<JobPostEntity> _filteredJobs = []; // Jobs sau khi filter
  String? _errorMessage;
  JobFilterModel _filter = const JobFilterModel();

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
  List<JobPostEntity> get jobs => _filteredJobs;
  List<JobPostEntity> get allJobs => _allJobs;
  String? get errorMessage => _errorMessage;
  bool get hasJobs => _filteredJobs.isNotEmpty;
  JobFilterModel get filter => _filter;
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

  /// Fetch jobs
  Future<void> fetchJobs() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final result = await getJobsUseCase();

    result.fold(
      (failure) {
        // Fetch thất bại
        _isLoading = false;
        _errorMessage = failure.message;
        notifyListeners();
      },
      (jobs) {
        // Fetch thành công
        _isLoading = false;
        _allJobs = jobs;
        _applyFilter(); // Apply current filter
        _errorMessage = null;
        notifyListeners();
      },
    );
  }

  /// Update filter and apply
  void updateFilter(JobFilterModel newFilter) {
    _filter = newFilter;
    _applyFilter();
    notifyListeners();
  }

  /// Clear all filters
  void clearFilter() {
    _filter = const JobFilterModel();
    _applyFilter();
    notifyListeners();
  }

  /// Apply filter to jobs
  void _applyFilter() {
    _filteredJobs = _allJobs.where((job) {
      // 1. Keyword search (title or company name)
      if (_filter.keyword.isNotEmpty) {
        final keyword = _filter.keyword.toLowerCase();
        final matchesTitle = job.title.toLowerCase().contains(keyword);
        final matchesCompany = job.companyName.toLowerCase().contains(keyword);
        if (!matchesTitle && !matchesCompany) return false;
      }

      // 2. Cities filter
      if (_filter.cities.isNotEmpty) {
        if (!_filter.cities.contains(job.cityName)) return false;
      }

      // 3. Salary range filter
      if (_filter.salaryRange != SalaryRange.all) {
        if (!_matchesSalaryRange(job)) return false;
      }

      // 4. Job types filter
      if (_filter.jobTypes.isNotEmpty) {
        if (!_filter.jobTypes.contains(job.jobType)) return false;
      }

      // 5. Job levels filter
      if (_filter.jobLevels.isNotEmpty) {
        if (!_filter.jobLevels.contains(job.jobLevel)) return false;
      }

      // 6. Education levels filter
      if (_filter.educationLevels.isNotEmpty) {
        if (!_matchesEducation(job)) return false;
      }

      // 7. Industries filter
      if (_filter.industries.isNotEmpty) {
        if (!_filter.industries.contains(job.industryName)) return false;
      }

      return true;
    }).toList();
  }

  /// Check if job matches salary range
  bool _matchesSalaryRange(JobPostEntity job) {
    switch (_filter.salaryRange) {
      case SalaryRange.under10:
        return job.salaryMax != null && job.salaryMax! < 10000000;
      case SalaryRange.from10To20:
        return (job.salaryMin != null && job.salaryMin! >= 10000000) &&
            (job.salaryMax != null && job.salaryMax! <= 20000000);
      case SalaryRange.from20To50:
        return (job.salaryMin != null && job.salaryMin! >= 20000000) &&
            (job.salaryMax != null && job.salaryMax! <= 50000000);
      case SalaryRange.above50:
        return job.salaryMin != null && job.salaryMin! > 50000000;
      case SalaryRange.negotiable:
        return job.salaryType == 'negotiable';
      case SalaryRange.all:
        return true;
    }
  }

  /// Check if job matches education requirement
  bool _matchesEducation(JobPostEntity job) {
    final education = job.educationRequired?.toLowerCase() ?? '';

    for (final level in _filter.educationLevels) {
      if (level == 'Không yêu cầu' && education.isEmpty) return true;
      if (education.contains(level.toLowerCase())) return true;
    }

    return false;
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
