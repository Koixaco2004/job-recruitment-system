import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/application_note_entity.dart';
import '../repositories/application_repository.dart';

class UpdateApplicationNoteUseCase {
  final ApplicationRepository repository;

  UpdateApplicationNoteUseCase(this.repository);

  Future<Either<Failure, ApplicationNoteEntity>> call({
    required int noteId,
    required String content,
  }) async {
    return await repository.updateApplicationNote(
      noteId: noteId,
      content: content,
    );
  }
}
