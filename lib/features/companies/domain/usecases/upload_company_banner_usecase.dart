import 'dart:typed_data';
import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../repositories/company_repository.dart';

class UploadCompanyBannerUseCase {
  final CompanyRepository repository;

  UploadCompanyBannerUseCase(this.repository);

  Future<Either<Failure, String>> call(Uint8List bytes, String fileName) async {
    return await repository.uploadBanner(bytes, fileName);
  }
}
