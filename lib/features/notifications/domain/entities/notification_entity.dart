import 'package:equatable/equatable.dart';

class NotificationEntity extends Equatable {
  final int id;
  final int userId;
  final String type;
  final String title;
  final String content;
  final Map<String, dynamic> metadata;
  final bool isRead;
  final DateTime createdAt;
  final DateTime updatedAt;

  const NotificationEntity({
    required this.id,
    required this.userId,
    required this.type,
    required this.title,
    required this.content,
    required this.metadata,
    required this.isRead,
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  List<Object?> get props => [
        id,
        userId,
        type,
        title,
        content,
        metadata,
        isRead,
        createdAt,
        updatedAt,
      ];
}
