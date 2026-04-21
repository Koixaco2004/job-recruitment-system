import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/notification_entity.dart';

abstract class NotificationRepository {
  Future<Either<Failure, List<NotificationEntity>>> getNotifications({
    required int page,
    required int limit,
  });

  Future<Either<Failure, int>> getUnreadCount();

  Future<Either<Failure, bool>> markAsRead(int id);

  Future<Either<Failure, bool>> markAllAsRead();
}
