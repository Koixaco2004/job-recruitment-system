import '../../domain/entities/application_kanban_column_entity.dart';
import 'application_model.dart';

class ApplicationKanbanColumnModel extends ApplicationKanbanColumnEntity {
  const ApplicationKanbanColumnModel({
    required super.id,
    required super.title,
    required super.count,
    required super.items,
  });

  factory ApplicationKanbanColumnModel.fromJson(Map<String, dynamic> json) {
    return ApplicationKanbanColumnModel(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? 'Unknown',
      count: json['count'] as int? ?? 0,
      items: json['items'] != null
          ? (json['items'] as List)
              .map((e) => ApplicationModel.fromJson(e as Map<String, dynamic>))
              .toList()
          : [],
    );
  }
}
