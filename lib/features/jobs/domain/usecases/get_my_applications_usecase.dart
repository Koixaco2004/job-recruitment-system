import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/application_entity.dart';
import '../repositories/job_repository.dart';

/// UseCase để lấy danh sách đơn ứng tuyển của candidate
class GetMyApplicationsUseCase {
  final JobRepository repository;

  GetMyApplicationsUseCase(this.repository);

  Future<Either<Failure, List<ApplicationEntity>>> call(int candidateId) async {
    return await repository.getMyApplications(candidateId);
  }
}
