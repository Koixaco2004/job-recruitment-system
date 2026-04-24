import 'package:equatable/equatable.dart';

/// Entity cho học vấn
class EducationEntity extends Equatable {
  final int? id;
  final String institution;
  final String degree; // Enum: postgraduate, university, college, intermediate, high_school, certificate, none
  final String fieldOfStudy;
  final DateTime startDate;
  final DateTime? endDate;
  final String? description;

  const EducationEntity({
    this.id,
    required this.institution,
    required this.degree,
    required this.fieldOfStudy,
    required this.startDate,
    this.endDate,
    this.description,
  });

  @override
  List<Object?> get props => [
    id,
    institution,
    degree,
    fieldOfStudy,
    startDate,
    endDate,
    description,
  ];
}
