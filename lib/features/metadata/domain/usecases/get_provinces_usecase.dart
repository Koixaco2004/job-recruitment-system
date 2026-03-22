import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/province_entity.dart';
import '../repositories/metadata_repository.dart';

class GetProvincesUseCase {
  final MetadataRepository repository;

  GetProvincesUseCase(this.repository);

  Future<Either<Failure, List<ProvinceEntity>>> call() async {
    return await repository.getProvinces();
  }
}
