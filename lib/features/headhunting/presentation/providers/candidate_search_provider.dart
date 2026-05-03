import 'package:flutter/material.dart';
import '../../domain/entities/headhunting_candidate_entity.dart';
import '../../domain/models/candidate_filter_model.dart';
import '../../domain/usecases/search_candidates_usecase.dart';
import '../../../profile/domain/entities/skill_entity.dart';

class CandidateSearchProvider extends ChangeNotifier {
  final SearchCandidatesUseCase searchCandidatesUseCase;

  CandidateSearchProvider({required this.searchCandidatesUseCase});

  List<HeadhuntingCandidateEntity> _candidates = [];
  List<HeadhuntingCandidateEntity> get candidates => _candidates;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  CandidateFilterModel _filter = const CandidateFilterModel();
  CandidateFilterModel get filter => _filter;

  int _totalCount = 0;
  int get totalCount => _totalCount;

  bool _hasMore = true;
  bool get hasMore => _hasMore;

  int _totalSkillsCount = 0;
  int get totalSkillsCount => _totalSkillsCount;

  List<SkillEntity> _selectedSkillEntities = [];
  List<SkillEntity> get selectedSkillEntities => _selectedSkillEntities;

  Future<void> searchCandidates({bool refresh = true}) async {
    if (_isLoading) return; // Chặn yêu cầu nếu đang tải
    
    if (refresh) {
      _filter = _filter.copyWith(page: 1);
      _candidates = [];
      _hasMore = true;
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();
    } else {
      if (!_hasMore || _isLoading) return;
      _isLoading = true;
      notifyListeners();
    }

    final result = await searchCandidatesUseCase(
      keyword: _filter.keyword,
      provinceId: _filter.provinceId,
      minExperience: _filter.minExperience,
      categoryIds: _filter.categoryIds,
      skillIds: _filter.skillIds,
      jobTypeId: _filter.jobTypeId,
      salaryMin: _filter.salaryMin,
      salaryMax: _filter.salaryMax,
      requiredDegree: _filter.requiredDegree,
      jobId: _filter.jobId,
      sortBy: _filter.sortBy,
      sortOrder: _filter.sortOrder,
      scoring: _filter.scoring,
      page: _filter.page,
    );

    result.fold(
      (failure) {
        _errorMessage = failure.message;
        _isLoading = false;
        notifyListeners();
      },
      (data) {
        final List<HeadhuntingCandidateEntity> newCandidates = data['candidates'] ?? [];
        if (refresh) {
          _candidates = newCandidates;
        } else {
          // Tránh trùng lặp ID khi addAll
          final existingIds = _candidates.map((c) => c.id).toSet();
          final uniqueNewCandidates = newCandidates.where((c) => !existingIds.contains(c.id)).toList();
          _candidates.addAll(uniqueNewCandidates);
        }

        _totalCount = data['total'] ?? 0;
        _totalSkillsCount = data['totalSkillsCount'] ?? 0;
        final int lastPage = data['lastPage'] ?? 1;
        _hasMore = _filter.page < lastPage;

        if (_hasMore) {
          _filter = _filter.copyWith(page: _filter.page + 1);
        }

        _isLoading = false;
        notifyListeners();
      },
    );
  }

  void updateFilter(CandidateFilterModel newFilter, {List<SkillEntity>? selectedSkills}) {
    _filter = newFilter;
    if (selectedSkills != null) {
      _selectedSkillEntities = selectedSkills;
    }
    searchCandidates(refresh: true);
  }

  void clearFilter() {
    _filter = const CandidateFilterModel();
    _selectedSkillEntities = [];
    searchCandidates(refresh: true);
  }
}
