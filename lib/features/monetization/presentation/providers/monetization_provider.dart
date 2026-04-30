import 'package:flutter/material.dart';
import '../../domain/entities/subscription_package_entity.dart';
import '../../domain/entities/topup_pack_entity.dart';
import '../../domain/entities/subscription_entity.dart';
import '../../domain/entities/credit_transaction_entity.dart';
import '../../domain/entities/credit_product_entity.dart';
import '../../domain/repositories/monetization_repository.dart';

class MonetizationProvider extends ChangeNotifier {
  final MonetizationRepository repository;

  MonetizationProvider({required this.repository});

  bool _isLoading = false;
  List<SubscriptionPackageEntity> _packages = [];
  List<TopupPackEntity> _topupPacks = [];
  SubscriptionEntity? _currentSubscription;
  String? _errorMessage;
  List<CreditProductEntity> _creditProducts = [];

  // Subscription Status
  int _creditBalance = 0;
  bool _isLoadingStatus = false;
  List<CreditTransactionEntity> _transactions = [];
  int _transactionPage = 1;
  int _transactionLastPage = 1;
  bool _isLoadingTransactions = false;

  bool get isLoading => _isLoading;
  List<SubscriptionPackageEntity> get packages => _packages;
  List<TopupPackEntity> get topupPacks => _topupPacks;
  List<CreditProductEntity> get creditProducts => _creditProducts;
  String? get errorMessage => _errorMessage;

  SubscriptionEntity? get currentSubscription => _currentSubscription;
  int get creditBalance => _creditBalance;
  bool get isLoadingStatus => _isLoadingStatus;
  List<CreditTransactionEntity> get transactions => _transactions;
  bool get isLoadingTransactions => _isLoadingTransactions;
  bool get hasMoreTransactions => _transactionPage < _transactionLastPage;

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

  Future<void> fetchCreditTransactions({bool refresh = false}) async {
    if (refresh) {
      _transactionPage = 1;
      _transactions = [];
    } else if (!hasMoreTransactions && _transactions.isNotEmpty) {
      return;
    }

    _isLoadingTransactions = true;
    notifyListeners();

    final result = await repository.getCreditTransactions(
      page: refresh ? 1 : _transactionPage + 1,
    );

    result.fold(
      (failure) => _errorMessage = failure.message,
      (data) {
        final List<CreditTransactionEntity> newTransactions = data['transactions'];
        if (refresh) {
          _transactions = newTransactions;
        } else {
          _transactions.addAll(newTransactions);
        }
        _transactionPage = data['page'];
        _transactionLastPage = data['lastPage'];
      },
    );

    _isLoadingTransactions = false;
    notifyListeners();
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

  Future<void> fetchCreditProducts() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final result = await repository.getCreditProducts();
    result.fold(
      (failure) {
        _errorMessage = failure.message;
        _isLoading = false;
        notifyListeners();
      },
      (products) {
        _creditProducts = products;
        _isLoading = false;
        notifyListeners();
      },
    );
  }

  Future<Map<String, dynamic>?> purchaseProduct({required String slug, int? targetJobId}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final result = await repository.purchaseProduct(slug: slug, targetJobId: targetJobId);
    return result.fold(
      (failure) {
        _errorMessage = failure.message;
        _isLoading = false;
        notifyListeners();
        return null;
      },
      (data) {
        _isLoading = false;
        notifyListeners();
        return data;
      },
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
