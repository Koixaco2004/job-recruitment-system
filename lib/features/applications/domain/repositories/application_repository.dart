import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/models/paginated_response.dart';
import '../entities/application_entity.dart';

abstract class ApplicationRepository {
  Future<Either<Failure, ApplicationEntity>> apply({
    required int jobId,
    String? coverLetter,
  });

  Future<Either<Failure, PaginatedResponse<ApplicationEntity>>> getMyApplications({
    int page = 1,
    int limit = 10,
    String? status,
  });

  Future<Either<Failure, ApplicationEntity>> getApplicationDetail(int id);

  Future<Either<Failure, void>> withdrawApplication(int id);
}
