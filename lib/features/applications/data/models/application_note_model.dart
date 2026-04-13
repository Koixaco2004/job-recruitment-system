import '../../domain/entities/application_note_entity.dart';

class ApplicationNoteModel extends ApplicationNoteEntity {
  const ApplicationNoteModel({
    required super.id,
    required super.applicationId,
    required super.authorId,
    required super.content,
    required super.createdAt,
    required super.updatedAt,
    required super.authorName,
    super.authorAvatar,
  });

  factory ApplicationNoteModel.fromJson(Map<String, dynamic> json) {
    // Note format from BE documentation:
    // {
    //   "id": number,
    //   "content": string,
    //   "createdAt": string (ISO),
    //   "authorId": number,
    //   "author": { "fullName": string, "avatarUrl": string | null }
    // }
    
    final author = json['author'] as Map<String, dynamic>?;
    
    return ApplicationNoteModel(
      id: json['id'] as int,
      applicationId: json['applicationId'] as int? ?? 0, // Backend doesn't always return this in detail
      authorId: json['authorId'] as int? ?? (author?['id'] as int? ?? 0),
      content: json['content'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] != null 
          ? DateTime.parse(json['updatedAt'] as String) 
          : DateTime.parse(json['createdAt'] as String),
      authorName: author?['fullName'] as String? ?? 'Unknown',
      authorAvatar: author?['avatarUrl'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'applicationId': applicationId,
      'authorId': authorId,
      'content': content,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}
