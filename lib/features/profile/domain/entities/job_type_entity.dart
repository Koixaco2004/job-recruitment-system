import 'package:equatable/equatable.dart';

class JobTypeEntity extends Equatable {
  final int id;
  final String name;

  const JobTypeEntity({
    required this.id,
    required this.name,
  });

  @override
  List<Object?> get props => [id, name];
}
