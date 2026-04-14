import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../repositories/profile_repository.dart';

class ParseCvUseCase {
  final ProfileRepository repository;

  ParseCvUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call() async {
    return await repository.parseCv();
  }
}
