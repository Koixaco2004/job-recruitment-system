import 'package:flutter/material.dart';
import '../../../../core/models/paginated_response.dart';
import '../../domain/entities/application_entity.dart';
import '../../domain/entities/application_kanban_column_entity.dart';
import '../../domain/entities/application_status_history_entity.dart';
import '../../domain/usecases/get_job_applications_usecase.dart';
import '../../domain/usecases/get_kanban_board_usecase.dart';
import '../../domain/usecases/get_employer_application_detail_usecase.dart';
import '../../domain/usecases/get_application_status_history_usecase.dart';
import '../../domain/usecases/update_application_status_usecase.dart';
import '../../domain/usecases/add_application_note_usecase.dart';
import '../../domain/usecases/update_application_note_usecase.dart';
import '../../domain/usecases/analyze_ai_usecase.dart';

class EmployerApplicationProvider with ChangeNotifier {
  final GetJobApplicationsUseCase getJobApplicationsUseCase;
  final GetKanbanBoardUseCase getKanbanBoardUseCase;
  final GetEmployerApplicationDetailUseCase getEmployerApplicationDetailUseCase;
  final GetApplicationStatusHistoryUseCase getApplicationStatusHistoryUseCase;
  final UpdateApplicationStatusUseCase updateApplicationStatusUseCase;
  final AddApplicationNoteUseCase addApplicationNoteUseCase;
  final UpdateApplicationNoteUseCase updateApplicationNoteUseCase;
  final AnalyzeAiUseCase analyzeAiUseCase;

  EmployerApplicationProvider({
    required this.getJobApplicationsUseCase,
    required this.getKanbanBoardUseCase,
    required this.getEmployerApplicationDetailUseCase,
    required this.getApplicationStatusHistoryUseCase,
    required this.updateApplicationStatusUseCase,
    required this.addApplicationNoteUseCase,
    required this.updateApplicationNoteUseCase,
    required this.analyzeAiUseCase,
  });

  List<ApplicationKanbanColumnEntity> _kanbanColumns = [];
  List<ApplicationKanbanColumnEntity> get kanbanColumns => _kanbanColumns;

  PaginatedResponse<ApplicationEntity>? _jobApplications;
  PaginatedResponse<ApplicationEntity>? get jobApplications => _jobApplications;

  ApplicationEntity? _selectedApplication;
  ApplicationEntity? get selectedApplication => _selectedApplication;

  bool _isLoadingKanban = false;
  bool get isLoadingKanban => _isLoadingKanban;

  bool _isLoadingList = false;
  bool get isLoadingList => _isLoadingList;

  bool _isLoadingDetail = false;
  bool get isLoadingDetail => _isLoadingDetail;

  bool _isLoadingHistory = false;
  bool get isLoadingHistory => _isLoadingHistory;

  List<ApplicationStatusHistoryEntity> _statusHistory = [];
  List<ApplicationStatusHistoryEntity> get statusHistory => _statusHistory;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  Future<void> fetchKanbanBoard(int jobId) async {
    _isLoadingKanban = true;
    _errorMessage = null;
    notifyListeners();

    final result = await getKanbanBoardUseCase(jobId);

    result.fold(
      (failure) {
        _errorMessage = failure.message;
        _isLoadingKanban = false;
      },
      (columns) {
        _kanbanColumns = columns;
        _isLoadingKanban = false;
      },
    );
    notifyListeners();
  }

  Future<void> fetchJobApplications(
    int jobId, {
    int page = 1,
    int limit = 10,
    String? status,
  }) async {
    _isLoadingList = true;
    _errorMessage = null;
    notifyListeners();

    final result = await getJobApplicationsUseCase(
      jobId,
      page: page,
      limit: limit,
      status: status,
    );

    result.fold(
      (failure) {
        _errorMessage = failure.message;
        _isLoadingList = false;
      },
      (paginatedResponse) {
        if (page == 1) {
          _jobApplications = paginatedResponse;
        } else {
          // Append data for pagination
          final currentItems = _jobApplications?.data ?? [];
          _jobApplications = PaginatedResponse(
            data: [...currentItems, ...paginatedResponse.data],
            total: paginatedResponse.total,
            page: paginatedResponse.page,
            lastPage: paginatedResponse.lastPage,
          );
        }
        _isLoadingList = false;
      },
    );
    notifyListeners();
  }

  Future<void> fetchApplicationDetail(int id) async {
    _isLoadingDetail = true;
    _selectedApplication = null;
    _errorMessage = null;
    notifyListeners();

    final result = await getEmployerApplicationDetailUseCase(id);

    result.fold(
      (failure) {
        _errorMessage = failure.message;
        _isLoadingDetail = false;
      },
      (application) {
        _selectedApplication = application;
        _isLoadingDetail = false;
        // Optionally fetch history automatically when detail is fetched
        fetchApplicationHistory(id);
      },
    );
    notifyListeners();
  }

  Future<void> fetchApplicationHistory(int id) async {
    _isLoadingHistory = true;
    _statusHistory = []; // Clear old history
    notifyListeners();

    final result = await getApplicationStatusHistoryUseCase(id);

    result.fold(
      (failure) {
        _errorMessage = failure.message;
        _isLoadingHistory = false;
      },
      (history) {
        _statusHistory = history;
        _isLoadingHistory = false;
      },
    );
    notifyListeners();
  }

  void clearSelectedApplication() {
    _selectedApplication = null;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  Future<bool> updateApplicationStatus(
    int id,
    String status, {
    String? reason,
    String? note,
  }) async {
    _isLoadingDetail = true;
    _errorMessage = null;
    notifyListeners();

    final result = await updateApplicationStatusUseCase(
      id: id,
      status: status,
      reason: reason,
      note: note,
    );

    return result.fold(
      (failure) {
        _errorMessage = failure.message;
        _isLoadingDetail = false;
        notifyListeners();
        return false;
      },
      (_) async {
        // Refresh local detail if it's the same application
        if (_selectedApplication?.id == id) {
          await fetchApplicationDetail(id);
        }
        // Refresh board
        if (_selectedApplication?.jobId != null) {
          await fetchKanbanBoard(_selectedApplication!.jobId);
          await fetchJobApplications(_selectedApplication!.jobId);
        }
        _isLoadingDetail = false;
        notifyListeners();
        return true;
      },
    );
  }

  Future<bool> addApplicationNote(int applicationId, String content) async {
    _isLoadingDetail = true;
    _errorMessage = null;
    notifyListeners();

    final result = await addApplicationNoteUseCase(
      applicationId: applicationId,
      content: content,
    );

    return result.fold(
      (failure) {
        _errorMessage = failure.message;
        _isLoadingDetail = false;
        notifyListeners();
        return false;
      },
      (note) async {
        // Refresh detail to get the updated notes list
        await fetchApplicationDetail(applicationId);
        _isLoadingDetail = false;
        notifyListeners();
        return true;
      },
    );
  }

  Future<bool> updateApplicationNote(int applicationId, int noteId, String content) async {
    _isLoadingDetail = true;
    _errorMessage = null;
    notifyListeners();

    final result = await updateApplicationNoteUseCase(
      noteId: noteId,
      content: content,
    );

    return result.fold(
      (failure) {
        _errorMessage = failure.message;
        _isLoadingDetail = false;
        notifyListeners();
        return false;
      },
      (note) async {
        // Refresh detail to get the updated notes list
        await fetchApplicationDetail(applicationId);
        _isLoadingDetail = false;
        notifyListeners();
        return true;
      },
    );
  }

  Future<bool> analyzeAi(int applicationId) async {
    _isLoadingDetail = true;
    _errorMessage = null;
    notifyListeners();

    final result = await analyzeAiUseCase(applicationId);

    return result.fold(
      (failure) {
        _errorMessage = failure.message;
        _isLoadingDetail = false;
        notifyListeners();
        return false;
      },
      (application) {
        _selectedApplication = application;
        _isLoadingDetail = false;
        notifyListeners();
        return true;
      },
    );
  }
}
