import 'package:equatable/equatable.dart';

class ApplicationNoteEntity extends Equatable {
  final int id;
  final int applicationId;
  final int authorId;
  final String content;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String authorName;
  final String? authorAvatar;

  const ApplicationNoteEntity({
    required this.id,
    required this.applicationId,
    required this.authorId,
    required this.content,
    required this.createdAt,
    required this.updatedAt,
    required this.authorName,
    this.authorAvatar,
  });

  @override
  List<Object?> get props => [
        id,
        applicationId,
        authorId,
        content,
        createdAt,
        updatedAt,
        authorName,
        authorAvatar,
      ];
}
