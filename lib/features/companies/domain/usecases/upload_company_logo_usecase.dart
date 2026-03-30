import 'dart:typed_data';
import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../repositories/company_repository.dart';

class UploadCompanyLogoUseCase {
  final CompanyRepository repository;

  UploadCompanyLogoUseCase(this.repository);

  Future<Either<Failure, String>> call(Uint8List bytes, String fileName) async {
    return await repository.uploadLogo(bytes, fileName);
  }
}
