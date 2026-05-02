import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/subscription_package_entity.dart';
import '../../domain/entities/topup_pack_entity.dart';
import '../../domain/entities/subscription_entity.dart';
import '../../domain/entities/credit_product_entity.dart';
import '../../domain/repositories/monetization_repository.dart';
import '../datasources/monetization_remote_datasource.dart';
import '../models/credit_product_model.dart';

class MonetizationRepositoryImpl implements MonetizationRepository {
  final MonetizationRemoteDataSource remoteDataSource;

  MonetizationRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<SubscriptionPackageEntity>>> getSubscriptionPackages() async {
    try {
      final result = await remoteDataSource.getSubscriptionPackages();
      return Right(result);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<TopupPackEntity>>> getTopupPacks() async {
    try {
      final result = await remoteDataSource.getTopupPacks();
      return Right(result);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> createVipOrder() async {
    try {
      final result = await remoteDataSource.createVipOrder();
      return Right(result);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> createCreditOrder(String packSlug) async {
    try {
      final result = await remoteDataSource.createCreditOrder(packSlug);
      return Right(result);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> verifyVnpayPayment(Map<String, dynamic> queryParams) async {
    try {
      final result = await remoteDataSource.verifyVnpayPayment(queryParams);
      return Right(result);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, SubscriptionEntity>> getSubscriptionStatus() async {
    try {
      final result = await remoteDataSource.getSubscriptionStatus();
      return Right(result);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, int>> getCreditBalance() async {
    try {
      final result = await remoteDataSource.getCreditBalance();
      return Right(result);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> getCreditTransactions({int page = 1, int limit = 20}) async {
    try {
      final result = await remoteDataSource.getCreditTransactions(page: page, limit: limit);
      return Right(result);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<CreditProductEntity>>> getCreditProducts() async {
    try {
      final List<CreditProductModel> result = await remoteDataSource.getCreditProducts();
      return Right<Failure, List<CreditProductEntity>>(result.cast<CreditProductEntity>());
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> purchaseProduct({required String slug, int? targetJobId}) async {
    try {
      final result = await remoteDataSource.purchaseProduct(slug: slug, targetJobId: targetJobId);
      return Right(result);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
