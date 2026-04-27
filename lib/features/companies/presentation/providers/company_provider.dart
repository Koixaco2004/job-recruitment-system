import 'package:flutter/material.dart';
import '../../../jobs/domain/entities/job_post_entity.dart';
import '../../domain/entities/company_entity.dart';
import '../../domain/usecases/get_companies_usecase.dart';
import '../../domain/usecases/get_company_by_id_usecase.dart';
import '../../domain/usecases/get_company_by_slug_usecase.dart';
import '../../domain/usecases/get_company_jobs_usecase.dart';
import '../../domain/usecases/search_companies_usecase.dart';

/// Provider quản lý state cho Companies feature
class CompanyProvider extends ChangeNotifier {
  final GetCompaniesUseCase getCompaniesUseCase;
  final GetCompanyByIdUseCase getCompanyByIdUseCase;
  final GetCompanyBySlugUseCase getCompanyBySlugUseCase;
  final SearchCompaniesUseCase searchCompaniesUseCase;
  final GetCompanyJobsUseCase getCompanyJobsUseCase;

  CompanyProvider({
    required this.getCompaniesUseCase,
    required this.getCompanyByIdUseCase,
    required this.getCompanyBySlugUseCase,
    required this.searchCompaniesUseCase,
    required this.getCompanyJobsUseCase,
  });

  // State
  List<CompanyEntity> _companies = [];
  List<CompanyEntity> _filteredCompanies = [];
  CompanyEntity? _selectedCompany;
  List<JobPostEntity> _companyJobs = [];

  bool _isLoading = false;
  bool _isLoadingJobs = false;
  String? _error;
  String? _jobsError;
  String _searchQuery = '';
  bool _isGridView = true; // true = grid, false = list

  // Getters
  List<CompanyEntity> get companies => _filteredCompanies;
  CompanyEntity? get selectedCompany => _selectedCompany;
  List<JobPostEntity> get companyJobs => _companyJobs;
  bool get isLoading => _isLoading;
  bool get isLoadingJobs => _isLoadingJobs;
  String? get error => _error;
  String? get jobsError => _jobsError;
  String get searchQuery => _searchQuery;
  bool get isGridView => _isGridView;

  /// Lấy danh sách công ty
  Future<void> fetchCompanies() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    final result = await getCompaniesUseCase();

    result.fold(
      (failure) {
        _error = failure.message;
        _companies = [];
        _filteredCompanies = [];
      },
      (companies) {
        _companies = companies;
        _filteredCompanies = companies;
        _error = null;
      },
    );

    _isLoading = false;
    notifyListeners();
  }

  /// Tìm kiếm công ty
  Future<void> searchCompanies(String query) async {
    _searchQuery = query;

    if (query.isEmpty) {
      _filteredCompanies = _companies;
      notifyListeners();
      return;
    }

    _isLoading = true;
    notifyListeners();

    final result = await searchCompaniesUseCase(query);

    result.fold(
      (failure) {
        _error = failure.message;
        _filteredCompanies = [];
      },
      (companies) {
        _filteredCompanies = companies;
        _error = null;
      },
    );

    _isLoading = false;
    notifyListeners();
  }

  /// Lấy chi tiết công ty
  Future<void> fetchCompanyDetail(int employerId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    final result = await getCompanyByIdUseCase(employerId);

    result.fold(
      (failure) {
        _error = failure.message;
        _selectedCompany = null;
      },
      (company) {
        _selectedCompany = company;
        _error = null;
      },
    );

    _isLoading = false;
    notifyListeners();
  }

  /// Lấy chi tiết công ty theo Slug
  Future<void> fetchCompanyBySlug(String slug) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    final result = await getCompanyBySlugUseCase(slug);

    result.fold(
      (failure) {
        _error = failure.message;
        _selectedCompany = null;
      },
      (company) {
        _selectedCompany = company;
        _error = null;
      },
    );

    _isLoading = false;
    notifyListeners();
  }

  /// Lấy danh sách việc làm của công ty
  Future<void> fetchCompanyJobs(String slug) async {
    _isLoadingJobs = true;
    _jobsError = null;
    notifyListeners();

    final result = await getCompanyJobsUseCase(slug);

    result.fold(
      (failure) {
        _jobsError = failure.message;
        _companyJobs = [];
      },
      (jobs) {
        // Sắp xếp theo job mới nhất (createdAt descending)
        jobs.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        _companyJobs = jobs;
        _jobsError = null;
      },
    );

    _isLoadingJobs = false;
    notifyListeners();
  }

  /// Toggle giữa Grid và List view
  void toggleViewMode() {
    _isGridView = !_isGridView;
    notifyListeners();
  }

  /// Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
