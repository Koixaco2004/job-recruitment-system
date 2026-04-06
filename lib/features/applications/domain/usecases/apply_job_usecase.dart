import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/application_entity.dart';
import '../repositories/application_repository.dart';

class ApplyJobUseCase {
  final ApplicationRepository repository;

  ApplyJobUseCase(this.repository);

  Future<Either<Failure, ApplicationEntity>> call({
    required int jobId,
    String? coverLetter,
  }) async {
    return await repository.apply(
      jobId: jobId,
      coverLetter: coverLetter,
    );
  }
}
