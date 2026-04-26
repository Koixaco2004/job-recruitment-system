import 'package:flutter/material.dart';
import '../../domain/entities/application_entity.dart';
import '../../domain/entities/saved_job_entity.dart';
import '../../domain/usecases/get_my_applications_usecase.dart';
import '../../domain/usecases/get_saved_jobs_usecase.dart';
import '../../domain/usecases/save_job_usecase.dart';
import '../../domain/usecases/unsave_job_usecase.dart';
import '../../domain/usecases/unsave_job_by_post_id_usecase.dart';

import '../../domain/usecases/is_job_saved_usecase.dart';

/// Provider quản lý state cho My Jobs (Saved Jobs + Applications)
class MyJobsProvider extends ChangeNotifier {
  final GetSavedJobsUseCase getSavedJobsUseCase;
  final SaveJobUseCase saveJobUseCase;
  final UnsaveJobUseCase unsaveJobUseCase;
  final UnsaveJobByPostIdUseCase unsaveJobByPostIdUseCase;
  final GetMyApplicationsUseCase getMyApplicationsUseCase;
  final IsJobSavedUseCase isJobSavedUseCase;

  MyJobsProvider({
    required this.getSavedJobsUseCase,
    required this.saveJobUseCase,
    required this.unsaveJobUseCase,
    required this.unsaveJobByPostIdUseCase,
    required this.getMyApplicationsUseCase,
    required this.isJobSavedUseCase,
  });

  // State
  bool _isLoadingSaved = false;
  bool _isLoadingApplications = false;
  List<SavedJobEntity> _savedJobs = [];
  List<ApplicationEntity> _applications = [];
  String? _savedJobsError;
  String? _applicationsError;

  // Map để track saved state theo jobPostId
  final Map<int, bool> _savedJobsMap = {};

  // Getters
  bool get isLoadingSaved => _isLoadingSaved;
  bool get isLoadingApplications => _isLoadingApplications;
  List<SavedJobEntity> get savedJobs => _savedJobs;
  List<ApplicationEntity> get applications => _applications;
  String? get savedJobsError => _savedJobsError;
  String? get applicationsError => _applicationsError;
  bool get hasSavedJobs => _savedJobs.isNotEmpty;
  bool get hasApplications => _applications.isNotEmpty;

  /// Kiểm tra job đã được lưu chưa
  bool isJobSaved(int jobPostId) {
    return _savedJobsMap[jobPostId] ?? false;
  }

  /// Fetch saved jobs
  Future<void> fetchSavedJobs(int candidateId) async {
    _isLoadingSaved = true;
    _savedJobsError = null;
    notifyListeners();

    final result = await getSavedJobsUseCase(candidateId);

    result.fold(
      (failure) {
        _isLoadingSaved = false;
        _savedJobsError = failure.message;
        notifyListeners();
      },
      (jobs) {
        _isLoadingSaved = false;
        _savedJobs = jobs;
        _savedJobsError = null;

        // Update map
        _savedJobsMap.clear();
        for (final job in jobs) {
          _savedJobsMap[job.jobPostId] = true;
        }

        notifyListeners();
      },
    );
  }

  /// Fetch applications
  Future<void> fetchApplications(int candidateId) async {
    _isLoadingApplications = true;
    _applicationsError = null;
    notifyListeners();

    final result = await getMyApplicationsUseCase(candidateId);

    result.fold(
      (failure) {
        _isLoadingApplications = false;
        _applicationsError = failure.message;
        notifyListeners();
      },
      (apps) {
        _isLoadingApplications = false;
        _applications = apps;
        _applicationsError = null;
        notifyListeners();
      },
    );
  }

  /// Save job
  Future<bool> saveJob({
    required int candidateId,
    required int jobPostId,
  }) async {
    final result = await saveJobUseCase(
      candidateId: candidateId,
      jobPostId: jobPostId,
    );

    return result.fold(
      (failure) {
        _savedJobsError = failure.message;
        notifyListeners();
        return false;
      },
      (savedJob) {
        // Thêm vào danh sách
        _savedJobs.insert(0, savedJob);
        _savedJobsMap[jobPostId] = true;
        notifyListeners();
        return true;
      },
    );
  }

  /// Unsave job by savedJobId
  Future<bool> unsaveJob(int savedJobId) async {
    final result = await unsaveJobUseCase(savedJobId);

    return result.fold(
      (failure) {
        _savedJobsError = failure.message;
        notifyListeners();
        return false;
      },
      (_) {
        // Xóa khỏi danh sách
        final job = _savedJobs.firstWhere((j) => j.savedJobId == savedJobId);
        _savedJobs.removeWhere((job) => job.savedJobId == savedJobId);
        _savedJobsMap[job.jobPostId] = false;
        notifyListeners();
        return true;
      },
    );
  }

  /// Unsave job by jobPostId
  Future<bool> unsaveJobByJobPostId({
    required int candidateId,
    required int jobPostId,
  }) async {
    final result = await unsaveJobByPostIdUseCase(
      candidateId: candidateId,
      jobPostId: jobPostId,
    );

    return result.fold(
      (failure) {
        _savedJobsError = failure.message;
        notifyListeners();
        return false;
      },
      (_) {
        // Xóa khỏi danh sách
        _savedJobs.removeWhere((job) => job.jobPostId == jobPostId);
        _savedJobsMap[jobPostId] = false;
        notifyListeners();
        return true;
      },
    );
  }

  /// Toggle save job
  Future<bool> toggleSaveJob({
    required int candidateId,
    required int jobPostId,
  }) async {
    final currentlySaved = isJobSaved(jobPostId);

    if (currentlySaved) {
      return await unsaveJobByJobPostId(
        candidateId: candidateId,
        jobPostId: jobPostId,
      );
    } else {
      return await saveJob(
        candidateId: candidateId,
        jobPostId: jobPostId,
      );
    }
  }

  /// Kiểm tra trạng thái lưu từ API
  Future<bool> checkJobSaved({
    required int candidateId,
    required int jobPostId,
  }) async {
    final result = await isJobSavedUseCase(
      candidateId: candidateId,
      jobPostId: jobPostId,
    );

    return result.fold(
      (failure) => false,
      (isSaved) {
        _savedJobsMap[jobPostId] = isSaved;
        notifyListeners();
        return isSaved;
      },
    );
  }

  /// Clear errors
  void clearErrors() {
    _savedJobsError = null;
    _applicationsError = null;
    notifyListeners();
  }
}
