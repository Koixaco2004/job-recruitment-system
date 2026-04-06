import 'package:equatable/equatable.dart';

class ApplicationStatusHistoryEntity extends Equatable {
  final int id;
  final int applicationId;
  final String? oldStatus;
  final String newStatus;
  final String? reason;
  final int? changedById;
  final DateTime createdAt;

  const ApplicationStatusHistoryEntity({
    required this.id,
    required this.applicationId,
    this.oldStatus,
    required this.newStatus,
    this.reason,
    this.changedById,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [
        id,
        applicationId,
        oldStatus,
        newStatus,
        reason,
        changedById,
        createdAt,
      ];
}
