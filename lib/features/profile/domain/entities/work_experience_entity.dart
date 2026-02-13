import 'package:equatable/equatable.dart';

/// Entity cho kinh nghiệm làm việc
class WorkExperienceEntity extends Equatable {
  final int? id;
  final String companyName;
  final String position;
  final DateTime startDate;
  final DateTime? endDate; // null = đang làm
  final String? description;
  final bool isCurrentJob;

  const WorkExperienceEntity({
    this.id,
    required this.companyName,
    required this.position,
    required this.startDate,
    this.endDate,
    this.description,
    this.isCurrentJob = false,
  });

  @override
  List<Object?> get props => [
    id,
    companyName,
    position,
    startDate,
    endDate,
    description,
    isCurrentJob,
  ];
}
