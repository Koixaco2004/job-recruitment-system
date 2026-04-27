import 'package:flutter/material.dart';
import '../../domain/entities/subscription_package_entity.dart';
import '../../domain/entities/topup_pack_entity.dart';
import '../../domain/entities/subscription_entity.dart';
import '../../domain/repositories/monetization_repository.dart';

class MonetizationProvider extends ChangeNotifier {
  final MonetizationRepository repository;

  MonetizationProvider({required this.repository});

  bool _isLoading = false;
  List<SubscriptionPackageEntity> _packages = [];
  List<TopupPackEntity> _topupPacks = [];
  SubscriptionEntity? _currentSubscription;
  String? _errorMessage;

  // Subscription Status
  int _creditBalance = 0;
  bool _isLoadingStatus = false;

  bool get isLoading => _isLoading;
  List<SubscriptionPackageEntity> get packages => _packages;
  List<TopupPackEntity> get topupPacks => _topupPacks;
  String? get errorMessage => _errorMessage;

  SubscriptionEntity? get currentSubscription => _currentSubscription;
  int get creditBalance => _creditBalance;
  bool get isLoadingStatus => _isLoadingStatus;

  Future<void> fetchPackages() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final result = await repository.getSubscriptionPackages();
    result.fold(
      (failure) {
        _errorMessage = failure.message;
        _isLoading = false;
        notifyListeners();
      },
      (packages) {
        _packages = packages;
        _isLoading = false;
        notifyListeners();
      },
    );
  }

  Future<void> fetchTopupPacks() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final result = await repository.getTopupPacks();
    result.fold(
      (failure) {
        _errorMessage = failure.message;
        _isLoading = false;
        notifyListeners();
      },
      (packs) {
        _topupPacks = packs;
        _isLoading = false;
        notifyListeners();
      },
    );
  }

  Future<void> fetchSubscriptionStatus() async {
    _isLoadingStatus = true;
    _errorMessage = null;
    notifyListeners();

    final result = await repository.getSubscriptionStatus();
    result.fold(
      (failure) {
        _errorMessage = failure.message;
        _currentSubscription = null;
      },
      (status) {
        _currentSubscription = status;
      },
    );

    _isLoadingStatus = false;
    notifyListeners();
  }

  Future<void> fetchCreditBalance() async {
    final result = await repository.getCreditBalance();
    result.fold(
      (failure) => null,
      (balance) {
        _creditBalance = balance;
        notifyListeners();
      },
    );
  }

  Future<String?> createVipOrder() async {
    final result = await repository.createVipOrder();
    return result.fold(
      (failure) => null,
      (data) => data['paymentUrl'] as String?,
    );
  }

  Future<String?> createCreditOrder(String packId) async {
    final result = await repository.createCreditOrder(packId);
    return result.fold(
      (failure) => null,
      (data) => data['paymentUrl'] as String?,
    );
  }

  void clear() {
    _packages = [];
    _topupPacks = [];
    _currentSubscription = null;
    _creditBalance = 0;
    _errorMessage = null;
    _isLoading = false;
    _isLoadingStatus = false;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
