import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../repositories/job_repository.dart';

/// UseCase để bỏ lưu việc làm
class UnsaveJobUseCase {
  final JobRepository repository;

  UnsaveJobUseCase(this.repository);

  Future<Either<Failure, void>> call(int savedJobId) async {
    return await repository.unsaveJob(savedJobId);
  }
}
