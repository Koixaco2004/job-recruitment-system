import 'package:equatable/equatable.dart';

/// Entity cho Dự án (Project)
class ProjectEntity extends Equatable {
  final int? id;
  final String name;
  final DateTime? startDate;
  final DateTime? endDate;
  final String? description;

  const ProjectEntity({
    this.id,
    required this.name,
    this.startDate,
    this.endDate,
    this.description,
  });

  @override
  List<Object?> get props => [
    id,
    name,
    startDate,
    endDate,
    description,
  ];
}
