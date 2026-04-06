import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../repositories/application_repository.dart';

class WithdrawApplicationUseCase {
  final ApplicationRepository repository;

  WithdrawApplicationUseCase(this.repository);

  Future<Either<Failure, void>> call(int id) async {
    return await repository.withdrawApplication(id);
  }
}
