import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/province_entity.dart';

abstract class MetadataRepository {
  Future<Either<Failure, List<ProvinceEntity>>> getProvinces();
}
