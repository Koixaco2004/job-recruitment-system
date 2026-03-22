import 'package:dartz/dartz.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/province_entity.dart';
import '../../domain/repositories/metadata_repository.dart';
import '../datasources/metadata_remote_datasource.dart';

class MetadataRepositoryImpl implements MetadataRepository {
  final MetadataRemoteDataSource remoteDataSource;

  MetadataRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<ProvinceEntity>>> getProvinces() async {
    try {
      final provinces = await remoteDataSource.getProvinces();
      return Right(provinces);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Lỗi truy xuất tỉnh thành: ${e.toString()}'));
    }
  }
}
