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
    
    final authorJson = json['author'] as Map<String, dynamic>?;
    final employerJson = authorJson?['employer'] as Map<String, dynamic>?;
    
    return ApplicationNoteModel(
      id: json['id'] as int,
      applicationId: json['applicationId'] as int? ?? 0,
      authorId: json['authorId'] as int? ?? (authorJson?['id'] as int? ?? 0),
      content: json['content'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] != null 
          ? DateTime.parse(json['updatedAt'] as String) 
          : DateTime.parse(json['createdAt'] as String),
      authorName: employerJson?['fullName'] as String? ?? authorJson?['fullName'] as String? ?? 'Unknown',
      authorAvatar: employerJson?['avatarUrl'] as String? ?? authorJson?['avatarUrl'] as String?,
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
