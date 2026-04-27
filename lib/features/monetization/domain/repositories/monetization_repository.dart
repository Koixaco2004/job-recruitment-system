import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/subscription_package_entity.dart';
import '../../domain/entities/topup_pack_entity.dart';
import '../../domain/entities/subscription_entity.dart';

abstract class MonetizationRepository {
  Future<Either<Failure, List<SubscriptionPackageEntity>>> getSubscriptionPackages();
  Future<Either<Failure, List<TopupPackEntity>>> getTopupPacks();
  Future<Either<Failure, Map<String, dynamic>>> createVipOrder();
  Future<Either<Failure, Map<String, dynamic>>> createCreditOrder(String packId);
  Future<Either<Failure, Map<String, dynamic>>> verifyVnpayPayment(Map<String, dynamic> queryParams);
  Future<Either<Failure, SubscriptionEntity>> getSubscriptionStatus();
  Future<Either<Failure, int>> getCreditBalance();
  Future<Either<Failure, Map<String, dynamic>>> getCreditTransactions({int page = 1, int limit = 20});
}
