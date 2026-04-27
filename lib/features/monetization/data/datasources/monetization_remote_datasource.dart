import 'package:dio/dio.dart';
import '../../../../core/network/api_client.dart';
import '../models/subscription_package_model.dart';
import '../models/topup_pack_model.dart';
import '../models/subscription_model.dart';
import '../models/credit_transaction_model.dart';

abstract class MonetizationRemoteDataSource {
  Future<List<SubscriptionPackageModel>> getSubscriptionPackages();
  Future<List<TopupPackModel>> getTopupPacks();
  Future<Map<String, dynamic>> createVipOrder();
  Future<Map<String, dynamic>> createCreditOrder(String packId);
  Future<Map<String, dynamic>> verifyVnpayPayment(Map<String, dynamic> queryParams);
  Future<SubscriptionModel> getSubscriptionStatus();
  Future<int> getCreditBalance();
  Future<Map<String, dynamic>> getCreditTransactions({int page = 1, int limit = 20});
}

class MonetizationRemoteDataSourceImpl implements MonetizationRemoteDataSource {
  final ApiClient apiClient;

  MonetizationRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<List<SubscriptionPackageModel>> getSubscriptionPackages() async {
    final response = await apiClient.dio.get('/api/subscriptions/packages');
    final List<dynamic> data = response.data;
    return data.map((json) => SubscriptionPackageModel.fromJson(json)).toList();
  }

  @override
  Future<List<TopupPackModel>> getTopupPacks() async {
    final response = await apiClient.dio.get('/api/credits/topup-packs');
    final List<dynamic> data = response.data;
    return data.map((json) => TopupPackModel.fromJson(json)).toList();
  }

  @override
  Future<Map<String, dynamic>> createVipOrder() async {
    final response = await apiClient.dio.post('/api/payments/vip/create-order');
    return response.data;
  }

  @override
  Future<Map<String, dynamic>> createCreditOrder(String packId) async {
    final response = await apiClient.dio.post(
      '/api/payments/credit/create-order',
      data: {'packId': packId},
    );
    return response.data;
  }

  @override
  Future<Map<String, dynamic>> verifyVnpayPayment(Map<String, dynamic> queryParams) async {
    // Backend sẽ xử lý xong và Redirect (302) về trang Web.
    // Trên Mobile, ta không muốn Dio tự chạy theo Redirect đó (vì link Web có thể lỗi localhost).
    final response = await apiClient.dio.get(
      '/api/payments/vnpay/return',
      queryParameters: queryParams,
      options: Options(
        followRedirects: false,
        validateStatus: (status) => status != null && status < 500,
      ),
    );

    // Nếu là Redirect (302), kiểm tra link Redirect để biết kết quả
    if (response.statusCode == 301 || response.statusCode == 302) {
      final location = response.headers.value('location') ?? '';
      if (location.contains('success=true')) {
        return {'status': 'success', 'message': 'Thanh toán thành công'};
      } else {
        return {'status': 'error', 'message': 'Thanh toán không thành công hoặc bị hủy'};
      }
    }

    return response.data;
  }

  @override
  Future<SubscriptionModel> getSubscriptionStatus() async {
    final response = await apiClient.dio.get('/api/subscriptions/my');
    return SubscriptionModel.fromJson(response.data);
  }

  @override
  Future<int> getCreditBalance() async {
    final response = await apiClient.dio.get('/api/credits/balance');
    return response.data['balance'] as int? ?? 0;
  }

  @override
  Future<Map<String, dynamic>> getCreditTransactions({int page = 1, int limit = 20}) async {
    final response = await apiClient.dio.get(
      '/api/credits/transactions',
      queryParameters: {'page': page, 'limit': limit},
    );
    
    final List<dynamic> list = response.data['data'];
    final transactions = list.map((json) => CreditTransactionModel.fromJson(json)).toList();
    
    return {
      'transactions': transactions,
      'total': response.data['total'],
      'page': response.data['page'],
      'lastPage': response.data['lastPage'],
    };
  }
}
