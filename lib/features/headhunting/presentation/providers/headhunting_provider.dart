import 'package:flutter/material.dart';
import '../../domain/entities/headhunting_candidate_entity.dart';
import '../../domain/usecases/get_suggested_candidates_usecase.dart';

class HeadhuntingProvider extends ChangeNotifier {
  final GetSuggestedCandidatesUseCase getSuggestedCandidatesUseCase;

  HeadhuntingProvider({required this.getSuggestedCandidatesUseCase});

  bool _isLoading = false;
  List<HeadhuntingCandidateEntity> _suggestedCandidates = [];
  String? _errorMessage;

  bool get isLoading => _isLoading;
  List<HeadhuntingCandidateEntity> get suggestedCandidates => _suggestedCandidates;
  String? get errorMessage => _errorMessage;

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

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
