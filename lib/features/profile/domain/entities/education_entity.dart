import 'package:equatable/equatable.dart';

/// Entity cho học vấn
class EducationEntity extends Equatable {
  final int? id;
  final String institution;
  final String degree; // 'Đại học', 'Cao đẳng', 'Thạc sĩ', 'Tiến sĩ'
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
