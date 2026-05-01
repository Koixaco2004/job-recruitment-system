import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/headhunting_quota_entity.dart';
import '../repositories/headhunting_repository.dart';

class GetHeadhuntingQuotaUseCase {
  final HeadhuntingRepository repository;

  GetHeadhuntingQuotaUseCase(this.repository);

  Future<Either<Failure, HeadhuntingQuotaEntity>> execute() async {
    return await repository.getHeadhuntingQuota();
  }
}
