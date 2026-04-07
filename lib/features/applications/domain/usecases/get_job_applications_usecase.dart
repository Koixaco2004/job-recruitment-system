import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/models/paginated_response.dart';
import '../entities/application_entity.dart';
import '../repositories/application_repository.dart';

class GetJobApplicationsUseCase {
  final ApplicationRepository repository;

  GetJobApplicationsUseCase(this.repository);

  Future<Either<Failure, PaginatedResponse<ApplicationEntity>>> call(
    int jobId, {
    int page = 1,
    int limit = 10,
    String? status,
  }) {
    return repository.getJobApplications(
      jobId,
      page: page,
      limit: limit,
      status: status,
    );
  }
}
