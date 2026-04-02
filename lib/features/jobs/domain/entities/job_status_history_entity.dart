import 'package:equatable/equatable.dart';

/// Entity đại diện cho lịch sử thay đổi trạng thái của tin tuyển dụng
class JobStatusHistoryEntity extends Equatable {
  final int id;
  final int jobPostId;
  final String oldStatus;
  final String newStatus;
  final String? reason;
  final int? changedById;
  final DateTime createdAt;

  const JobStatusHistoryEntity({
    required this.id,
    required this.jobPostId,
    required this.oldStatus,
    required this.newStatus,
    this.reason,
    this.changedById,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [
    id,
    jobPostId,
    oldStatus,
    newStatus,
    reason,
    changedById,
    createdAt,
  ];
}
