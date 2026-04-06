import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/models/paginated_response.dart';
import '../entities/application_entity.dart';
import '../repositories/application_repository.dart';

class GetMyApplicationsUseCase {
  final ApplicationRepository repository;

  GetMyApplicationsUseCase(this.repository);

  Future<Either<Failure, PaginatedResponse<ApplicationEntity>>> call({
    int page = 1,
    int limit = 10,
    String? status,
  }) async {
    return await repository.getMyApplications(
      page: page,
      limit: limit,
      status: status,
    );
  }
}
