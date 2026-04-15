import 'package:flutter/material.dart';
import '../../domain/entities/headhunting_candidate_entity.dart';
import '../../domain/entities/candidate_detail_entity.dart';
import '../../domain/usecases/get_suggested_candidates_usecase.dart';
import '../../domain/usecases/get_candidate_detail_usecase.dart';
import '../../domain/usecases/send_invitation_usecase.dart';

class HeadhuntingProvider extends ChangeNotifier {
  final GetSuggestedCandidatesUseCase getSuggestedCandidatesUseCase;
  final GetCandidateDetailUseCase getCandidateDetailUseCase;
  final SendInvitationUseCase sendInvitationUseCase;

  HeadhuntingProvider({
    required this.getSuggestedCandidatesUseCase,
    required this.getCandidateDetailUseCase,
    required this.sendInvitationUseCase,
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
  // Map candidateId to Set of jobIds already invited or identified as already invited
  final Map<int, Set<int>> _invitedCandidateJobs = {};

  bool get isLoading => _isLoading;
  List<HeadhuntingCandidateEntity> get suggestedCandidates => _suggestedCandidates;
  String? get errorMessage => _errorMessage;

  CandidateDetailEntity? get selectedCandidateDetail => _selectedCandidateDetail;
  bool get isLoadingDetail => _isLoadingDetail;
  String? get detailError => _detailError;

  bool get isSendingInvitation => _isSendingInvitation;
  String? get invitationError => _invitationError;

  bool isInvited(int candidateId, int jobId) {
    return _invitedCandidateJobs[candidateId]?.contains(jobId) ?? false;
  }

  Future<void> fetchSuggestedCandidates(int jobId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

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

  void clearError() {
    _errorMessage = null;
    _detailError = null;
    _invitationError = null;
    notifyListeners();
  }
}
