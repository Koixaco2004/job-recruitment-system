import 'package:flutter/material.dart';
import '../../domain/entities/application_entity.dart';
import '../../domain/usecases/apply_job_usecase.dart';
import '../../domain/usecases/get_my_applications_usecase.dart';
import '../../domain/usecases/get_application_detail_usecase.dart';
import '../../domain/usecases/withdraw_application_usecase.dart';

class ApplicationProvider extends ChangeNotifier {
  final ApplyJobUseCase applyJobUseCase;
  final GetMyApplicationsUseCase getMyApplicationsUseCase;
  final GetApplicationDetailUseCase getApplicationDetailUseCase;
  final WithdrawApplicationUseCase withdrawApplicationUseCase;

  ApplicationProvider({
    required this.applyJobUseCase,
    required this.getMyApplicationsUseCase,
    required this.getApplicationDetailUseCase,
    required this.withdrawApplicationUseCase,
  });

  // State
  bool _isLoading = false;
  bool _isApplying = false;
  bool _applySuccess = false;
  bool _isReapply = false;
  String? _applyError;
  
  List<ApplicationEntity> _myApplications = [];
  int _totalApplications = 0;
  int _currentPage = 1;
  int _lastPage = 1;

  ApplicationEntity? _currentApplication;
  bool _isLoadingList = false;
  String? _listError;
  
  bool _isLoadingDetail = false;
  String? _detailError;

  bool _isWithdrawing = false;
  String? _withdrawError;


  // Getters
  bool get isLoading => _isLoading;
  bool get isApplying => _isApplying;
  bool get applySuccess => _applySuccess;
  bool get isReapply => _isReapply;
  String? get applyError => _applyError;
  
  List<ApplicationEntity> get myApplications => _myApplications;
  int get totalApplications => _totalApplications;
  bool get hasMoreApplications => _currentPage < _lastPage;

  ApplicationEntity? get currentApplication => _currentApplication;
  bool get isLoadingList => _isLoadingList;
  String? get listError => _listError;
  bool get isLoadingDetail => _isLoadingDetail;
  String? get detailError => _detailError;

  bool get isWithdrawing => _isWithdrawing;
  String? get withdrawError => _withdrawError;


  Future<void> fetchMyApplications({bool refresh = true, String? status}) async {
    if (refresh) {
      _currentPage = 1;
      _myApplications = [];
    } else {
      if (_currentPage >= _lastPage) return;
      _currentPage++;
    }

    _isLoadingList = true;
    _listError = null;
    notifyListeners();

    final result = await getMyApplicationsUseCase(
      page: _currentPage,
      status: status,
    );

    result.fold(
      (failure) {
        _isLoadingList = false;
        _listError = failure.message;
        notifyListeners();
      },

      (paginatedResponse) {
        if (refresh) {
          _myApplications = paginatedResponse.data;
        } else {
          _myApplications.addAll(paginatedResponse.data);
        }
        _totalApplications = paginatedResponse.total;
        _lastPage = paginatedResponse.lastPage;
        _isLoadingList = false;
        notifyListeners();
      },


    );
  }

  Future<bool> apply({
    required int jobId,
    String? coverLetter,
    String? currentCvUrl,
  }) async {
    if (currentCvUrl == null || currentCvUrl.isEmpty) {
      _applyError = 'CV_MISSING';
      notifyListeners();
      return false;
    }

    _isApplying = true;
    _applySuccess = false;
    _isReapply = false;
    _applyError = null;
    notifyListeners();

    final result = await applyJobUseCase(
      jobId: jobId,
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
        // In reality, we might need a flag from backend to know if it's a re-apply 
        // or just check if status was withdrawn before. 
        // For now, let's assume if the backend returned 201 it's a success.
        // If the user wants a special message for re-apply, we might need to check previous state.
        
        // Let's check if the walkthrough mentioned reapplied field.
        // Backend ApplyJobDto doesn't have it, but the response might.
        // For now, I'll just set a flag if the user withdrew before (if tracked).
        
        _isReapply = false; // Placeholder logic
        
        notifyListeners();
        return true;
      },
    );
  }

  Future<void> getDetail(int id) async {
    _isLoadingDetail = true;
    _detailError = null;
    _currentApplication = null;
    notifyListeners();

    final result = await getApplicationDetailUseCase(id);

    result.fold(
      (failure) {
        _isLoadingDetail = false;
        _detailError = failure.message;
        notifyListeners();
      },
      (application) {
        _currentApplication = application;
        _isLoadingDetail = false;
        notifyListeners();
      },
    );
  }

  Future<bool> withdraw(int id) async {
    _isWithdrawing = true;
    _withdrawError = null;
    notifyListeners();

    final result = await withdrawApplicationUseCase(id);

    return result.fold(
      (failure) {
        _isWithdrawing = false;
        _withdrawError = failure.message;
        notifyListeners();
        return false;
      },
      (_) {
        _isWithdrawing = false;
        // Update local state if current application is the one withdrawn
        if (_currentApplication != null && _currentApplication!.id == id) {
          _currentApplication = ApplicationEntity(
            id: _currentApplication!.id,
            jobId: _currentApplication!.jobId,
            candidateId: _currentApplication!.candidateId,
            cvUrlSnapshot: _currentApplication!.cvUrlSnapshot,
            coverLetter: _currentApplication!.coverLetter,
            status: 'withdrawn',
            rejectionReason: _currentApplication!.rejectionReason,
            employerNote: _currentApplication!.employerNote,
            matchScore: _currentApplication!.matchScore,
            matchReasoning: _currentApplication!.matchReasoning,
            cvMatchScore: _currentApplication!.cvMatchScore,
            cvMatchReasoning: _currentApplication!.cvMatchReasoning,
            appliedAt: _currentApplication!.appliedAt,
            updatedAt: DateTime.now(),
            job: _currentApplication!.job,
            candidate: _currentApplication!.candidate,
            statusHistory: _currentApplication!.statusHistory,
          );
        }
        
        // Also update in list
        final index = _myApplications.indexWhere((a) => a.id == id);
        if (index != -1) {
          final old = _myApplications[index];
          _myApplications[index] = ApplicationEntity(
            id: old.id,
            jobId: old.jobId,
            candidateId: old.candidateId,
            cvUrlSnapshot: old.cvUrlSnapshot,
            coverLetter: old.coverLetter,
            status: 'withdrawn',
            rejectionReason: old.rejectionReason,
            employerNote: old.employerNote,
            matchScore: old.matchScore,
            matchReasoning: old.matchReasoning,
            cvMatchScore: old.cvMatchScore,
            cvMatchReasoning: old.cvMatchReasoning,
            appliedAt: old.appliedAt,
            updatedAt: DateTime.now(),
            job: old.job,
            candidate: old.candidate,
            statusHistory: old.statusHistory,
          );
        }
        
        notifyListeners();
        return true;
      },
    );
  }

  void resetApplyState() {
    _applySuccess = false;
    _applyError = null;
    _isReapply = false;
    notifyListeners();
  }
}
