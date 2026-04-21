import '../../domain/entities/notification_entity.dart';

class NotificationModel extends NotificationEntity {
  const NotificationModel({
    required super.id,
    required super.userId,
    required super.type,
    required super.title,
    required super.content,
    required super.metadata,
    required super.isRead,
    required super.createdAt,
    required super.updatedAt,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    int _asInt(dynamic value) {
      if (value == null) return 0;
      if (value is int) return value;
      if (value is double) return value.toInt();
      if (value is String) return int.tryParse(value) ?? 0;
      return 0;
    }

    return NotificationModel(
      id: _asInt(json['id']),
      userId: _asInt(json['user_id'] ?? json['userId']),
      type: (json['type'] ?? '') as String,
      title: (json['title'] ?? '') as String,
      content: (json['content'] ?? '') as String,
      metadata: (json['metadata'] as Map<String, dynamic>?) ?? {},
      isRead: (json['is_read'] ?? json['isRead'] ?? false) as bool,
      createdAt: DateTime.parse((json['created_at'] ?? json['createdAt'] ?? DateTime.now().toIso8601String()) as String),
      updatedAt: DateTime.parse((json['updated_at'] ?? json['updatedAt'] ?? DateTime.now().toIso8601String()) as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'type': type,
      'title': title,
      'content': content,
      'metadata': metadata,
      'is_read': isRead,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  NotificationEntity toEntity() {
    return NotificationEntity(
      id: id,
      userId: userId,
      type: type,
      title: title,
      content: content,
      metadata: metadata,
      isRead: isRead,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}
