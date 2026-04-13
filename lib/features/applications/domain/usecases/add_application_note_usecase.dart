import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/application_note_entity.dart';
import '../repositories/application_repository.dart';

class AddApplicationNoteUseCase {
  final ApplicationRepository repository;

  AddApplicationNoteUseCase(this.repository);

  Future<Either<Failure, ApplicationNoteEntity>> call({
    required int applicationId,
    required String content,
  }) async {
    return await repository.addApplicationNote(
      applicationId: applicationId,
      content: content,
    );
  }
}
