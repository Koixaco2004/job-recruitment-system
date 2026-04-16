import 'package:flutter/material.dart';
import '../../domain/entities/headhunting_candidate_entity.dart';
import '../../domain/entities/candidate_detail_entity.dart';
import '../../domain/usecases/get_suggested_candidates_usecase.dart';
import '../../domain/usecases/get_candidate_detail_usecase.dart';
import '../../domain/usecases/send_invitation_usecase.dart';
import '../../domain/usecases/get_candidate_invitations_usecase.dart';
import '../../domain/usecases/accept_invitation_usecase.dart';
import '../../domain/usecases/decline_invitation_usecase.dart';
import '../../domain/entities/candidate_invitation_entity.dart';
import '../../domain/entities/employer_invitation_entity.dart';
import '../../domain/usecases/get_employer_invitations_usecase.dart';
import '../../../applications/domain/usecases/get_job_applications_usecase.dart';

class HeadhuntingProvider extends ChangeNotifier {
  final GetSuggestedCandidatesUseCase getSuggestedCandidatesUseCase;
  final GetCandidateDetailUseCase getCandidateDetailUseCase;
  final SendInvitationUseCase sendInvitationUseCase;
  final GetCandidateInvitationsUseCase getCandidateInvitationsUseCase;
  final AcceptInvitationUseCase acceptInvitationUseCase;
  final DeclineInvitationUseCase declineInvitationUseCase;
  final GetJobApplicationsUseCase getJobApplicationsUseCase;
  final GetEmployerInvitationsUseCase getEmployerInvitationsUseCase;

  HeadhuntingProvider({
    required this.getSuggestedCandidatesUseCase,
    required this.getCandidateDetailUseCase,
    required this.sendInvitationUseCase,
    required this.getCandidateInvitationsUseCase,
    required this.acceptInvitationUseCase,
    required this.declineInvitationUseCase,
    required this.getJobApplicationsUseCase,
    required this.getEmployerInvitationsUseCase,
  });

  bool _isLoading = false;
  List<HeadhuntingCandidateEntity> _suggestedCandidates = [];
  String? _errorMessage;

  // Detailed Candidate State
  CandidateDetailEntity? _selectedCandidateDetail;
  bool _isLoadingDetail = false;
  String? _detailError;

  // Invitation State
  bool _isSendingInvitation = false;
  String? _invitationError;

  // Candidate Side Invitations
  List<CandidateInvitationEntity> _candidateInvitations = [];
  bool _isLoadingInvitations = false;
  String? _candidateInvitationError;
  bool _isActionInProgress = false;
  // Map candidateId to Set of jobIds already invited or identified as already invited
  final Map<int, Set<int>> _invitedCandidateJobs = {};
  // Map jobId to Set of candidateIds who have applied
  final Map<int, Set<int>> _appliedCandidateJobs = {};
  
  // Employer Side Invitations
  List<EmployerInvitationEntity> _employerInvitations = [];
  bool _isLoadingEmployerInvitations = false;
  String? _employerInvitationError;

  bool get isLoading => _isLoading;
  List<HeadhuntingCandidateEntity> get suggestedCandidates => _suggestedCandidates;
  String? get errorMessage => _errorMessage;

  CandidateDetailEntity? get selectedCandidateDetail => _selectedCandidateDetail;
  bool get isLoadingDetail => _isLoadingDetail;
  String? get detailError => _detailError;

  bool get isSendingInvitation => _isSendingInvitation;
  String? get invitationError => _invitationError;

  // Candidate Getters
  List<CandidateInvitationEntity> get candidateInvitations => _candidateInvitations;
  bool get isLoadingInvitations => _isLoadingInvitations;
  String? get candidateInvitationError => _candidateInvitationError;
  bool get isActionInProgress => _isActionInProgress;
  int get pendingInvitationsCount => _candidateInvitations.where((i) => i.status == 'pending').length;
  
  // Employer Getters
  List<EmployerInvitationEntity> get employerInvitations => _employerInvitations;
  bool get isLoadingEmployerInvitations => _isLoadingEmployerInvitations;
  String? get employerInvitationError => _employerInvitationError;

  bool isInvited(int candidateId, int jobId) {
    return _invitedCandidateJobs[candidateId]?.contains(jobId) ?? false;
  }

  bool isApplied(int candidateId, int jobId) {
    return _appliedCandidateJobs[jobId]?.contains(candidateId) ?? false;
  }

  bool isInvitationAcceptedForJob(int jobId) {
    return _candidateInvitations.any((inv) => inv.jobId == jobId && inv.status == 'accepted');
  }

  Future<void> fetchSuggestedCandidates(int jobId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    // Fetch applications first to ensure we have the "Already Applied" status ready
    await fetchJobApplicants(jobId);
    
    // Then fetch suggested candidates
    final result = await getSuggestedCandidatesUseCase.execute(jobId);

    result.fold(
      (failure) {
        _errorMessage = failure.message;
        _isLoading = false;
        notifyListeners();
      },
      (candidates) {
        _suggestedCandidates = candidates;
        _isLoading = false;
        notifyListeners();
      },
    );
  }

  Future<void> fetchJobApplicants(int jobId) async {
    final result = await getJobApplicationsUseCase.call(jobId, limit: 100); // Get a good chunk of applicants
    result.fold(
      (failure) => null, // Ignore failures for sync
      (paginatedResponse) {
        final applicantIds = paginatedResponse.data.map((app) => app.candidateId).toSet();
        _appliedCandidateJobs[jobId] = applicantIds;
        notifyListeners();
      },
    );
  }

  Future<void> fetchCandidateDetail(int id) async {
    _isLoadingDetail = true;
    _detailError = null;
    _invitationError = null;
    _selectedCandidateDetail = null;
    notifyListeners();

    final result = await getCandidateDetailUseCase.call(id);

    result.fold(
      (failure) {
        _detailError = failure.message;
        _isLoadingDetail = false;
        notifyListeners();
      },
      (detail) {
        _selectedCandidateDetail = detail;
        _isLoadingDetail = false;
        notifyListeners();
      },
    );
  }

  Future<bool> sendInvitation({
    required int jobId,
    required int candidateId,
    required String message,
  }) async {
    _isSendingInvitation = true;
    _invitationError = null;
    notifyListeners();

    final result = await sendInvitationUseCase.call(SendInvitationParams(
      jobId: jobId,
      candidateId: candidateId,
      message: message,
    ));

    return result.fold(
      (failure) {
        _invitationError = failure.message;
        _isSendingInvitation = false;
        
        // If already invited, track it anyway to disable the button
        if (failure.message.contains('đã gửi thư mời') || failure.message.contains('vào vị trí này rồi')) {
          _invitedCandidateJobs.putIfAbsent(candidateId, () => {}).add(jobId);
        }
        
        notifyListeners();
        return false;
      },
      (success) {
        _isSendingInvitation = false;
        if (success) {
          _invitedCandidateJobs.putIfAbsent(candidateId, () => {}).add(jobId);
        }
        notifyListeners();
        return success;
      },
    );
  }

  // ─── Candidate Invitations Methods ──────────────────────────────────────

  Future<void> fetchCandidateInvitations() async {
    _isLoadingInvitations = true;
    _candidateInvitationError = null;
    notifyListeners();

    final result = await getCandidateInvitationsUseCase.execute();

    result.fold(
      (failure) {
        _candidateInvitationError = failure.message;
        _isLoadingInvitations = false;
        notifyListeners();
      },
      (invitations) {
        _candidateInvitations = invitations;
        _isLoadingInvitations = false;
        notifyListeners();
      },
    );
  }

  Future<bool> acceptCandidateInvitation(int id) async {
    // ─── START OPTIMISTIC UPDATE ───
    final index = _candidateInvitations.indexWhere((i) => i.id == id);
    CandidateInvitationEntity? originalInvitation;
    
    if (index != -1) {
      originalInvitation = _candidateInvitations[index];
      // Create a updated clone
      final updatedInvitation = CandidateInvitationEntity(
        id: originalInvitation.id,
        employerId: originalInvitation.employerId,
        candidateId: originalInvitation.candidateId,
        jobId: originalInvitation.jobId,
        message: originalInvitation.message,
        status: 'accepted',
        createdAt: originalInvitation.createdAt,
        updatedAt: DateTime.now(),
        employer: originalInvitation.employer,
        job: originalInvitation.job,
      );

      // Create new list reference to force rebuild everything (including badge)
      final newList = List<CandidateInvitationEntity>.from(_candidateInvitations);
      newList[index] = updatedInvitation;
      _candidateInvitations = newList;
      
      _candidateInvitationError = null;
      notifyListeners();
    }
    // ─── END OPTIMISTIC UPDATE ───

    _isActionInProgress = true;
    notifyListeners();

    final result = await acceptInvitationUseCase.execute(id);

    return result.fold(
      (failure) {
        // ─── ROLLBACK ON FAILURE ───
        if (index != -1 && originalInvitation != null) {
          final rollbackList = List<CandidateInvitationEntity>.from(_candidateInvitations);
          rollbackList[index] = originalInvitation;
          _candidateInvitations = rollbackList;
        }
        
        _candidateInvitationError = failure.message;
        _isActionInProgress = false;
        notifyListeners();
        return false;
      },
      (success) {
        if (!success) {
          // ─── ROLLBACK IF NOT SUCCESS ───
          if (index != -1 && originalInvitation != null) {
            final rollbackList = List<CandidateInvitationEntity>.from(_candidateInvitations);
            rollbackList[index] = originalInvitation;
            _candidateInvitations = rollbackList;
          }
        }
        _isActionInProgress = false;
        notifyListeners();
        return success;
      },
    );
  }

  Future<bool> declineCandidateInvitation(int id) async {
    // ─── START OPTIMISTIC UPDATE ───
    final index = _candidateInvitations.indexWhere((i) => i.id == id);
    CandidateInvitationEntity? originalInvitation;
    
    if (index != -1) {
      originalInvitation = _candidateInvitations[index];
      // Create a updated clone
      final updatedInvitation = CandidateInvitationEntity(
        id: originalInvitation.id,
        employerId: originalInvitation.employerId,
        candidateId: originalInvitation.candidateId,
        jobId: originalInvitation.jobId,
        message: originalInvitation.message,
        status: 'declined',
        createdAt: originalInvitation.createdAt,
        updatedAt: DateTime.now(),
        employer: originalInvitation.employer,
        job: originalInvitation.job,
      );

      // Create new list reference to force rebuild everything (including badge)
      final newList = List<CandidateInvitationEntity>.from(_candidateInvitations);
      newList[index] = updatedInvitation;
      _candidateInvitations = newList;
      
      _candidateInvitationError = null;
      notifyListeners();
    }
    // ─── END OPTIMISTIC UPDATE ───

    _isActionInProgress = true;
    notifyListeners();

    final result = await declineInvitationUseCase.execute(id);

    return result.fold(
      (failure) {
        // ─── ROLLBACK ON FAILURE ───
        if (index != -1 && originalInvitation != null) {
          final rollbackList = List<CandidateInvitationEntity>.from(_candidateInvitations);
          rollbackList[index] = originalInvitation;
          _candidateInvitations = rollbackList;
        }

        _candidateInvitationError = failure.message;
        _isActionInProgress = false;
        notifyListeners();
        return false;
      },
      (success) {
        if (!success) {
          // ─── ROLLBACK IF NOT SUCCESS ───
          if (index != -1 && originalInvitation != null) {
            final rollbackList = List<CandidateInvitationEntity>.from(_candidateInvitations);
            rollbackList[index] = originalInvitation;
            _candidateInvitations = rollbackList;
          }
        }
        _isActionInProgress = false;
        notifyListeners();
        return success;
      },
    );
  }

  void clearError() {
    _errorMessage = null;
    _detailError = null;
    _invitationError = null;
    _employerInvitationError = null;
    notifyListeners();
  }

  // ─── Employer Invitations Methods ────────────────────────────────────────

  Future<void> fetchEmployerInvitations() async {
    _isLoadingEmployerInvitations = true;
    _employerInvitationError = null;
    notifyListeners();

    final result = await getEmployerInvitationsUseCase.execute();

    result.fold(
      (failure) {
        _employerInvitationError = failure.message;
        _isLoadingEmployerInvitations = false;
        notifyListeners();
      },
      (invitations) {
        _employerInvitations = invitations;
        _isLoadingEmployerInvitations = false;
        notifyListeners();
      },
    );
  }
}
