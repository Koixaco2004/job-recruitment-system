import 'package:equatable/equatable.dart';

class JobCategoryEntity extends Equatable {
  final int id;
  final String name;
  final String slug;

  const JobCategoryEntity({
    required this.id,
    required this.name,
    required this.slug,
  });

  @override
  List<Object?> get props => [id, name, slug];
}
