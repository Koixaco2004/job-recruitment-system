import 'package:flutter/material.dart';
import '../../domain/entities/employer_entity.dart';
import '../../domain/usecases/employer_usecases.dart';

class EmployerProvider extends ChangeNotifier {
  final GetEmployerProfileUseCase getEmployerProfileUseCase;
  final SetupCompanyUseCase setupCompanyUseCase;

  EmployerProvider({
    required this.getEmployerProfileUseCase,
    required this.setupCompanyUseCase,
  });

  EmployerEntity? _employer;
  EmployerEntity? get employer => _employer;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  void clear() {
    _employer = null;
    _errorMessage = null;
    _isLoading = false;
    notifyListeners();
  }

  Future<void> getProfile() async {
    _employer = null; // Clear old data to prevent stale UI
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final result = await getEmployerProfileUseCase();

    result.fold(
      (failure) {
        _errorMessage = failure.message;
        _isLoading = false;
        notifyListeners();
      },
      (employer) {
        _employer = employer;
        _isLoading = false;
        notifyListeners();
      },
    );
  }

  Future<bool> setupCompany({
    required String fullName,
    required String phoneContact,
    required String companyName,
    required int categoryId,
    int? provinceId,
    String? address,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final result = await setupCompanyUseCase(
      fullName: fullName,
      phoneContact: phoneContact,
      companyName: companyName,
      categoryId: categoryId,
      provinceId: provinceId,
      address: address,
    );

    return result.fold(
      (failure) {
        _errorMessage = failure.message;
        _isLoading = false;
        notifyListeners();
        return false;
      },
      (_) async {
        // Refresh profile after setup
        await getProfile();
        return true;
      },
    );
  }
}
