import 'package:equatable/equatable.dart';
import 'application_entity.dart';

class ApplicationKanbanColumnEntity extends Equatable {
  final String id;
  final String title;
  final int count;
  final List<ApplicationEntity> items;

  const ApplicationKanbanColumnEntity({
    required this.id,
    required this.title,
    required this.count,
    required this.items,
  });

  @override
  List<Object?> get props => [id, title, count, items];
}
