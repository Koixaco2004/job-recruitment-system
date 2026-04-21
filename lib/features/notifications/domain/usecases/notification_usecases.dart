import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/notification_entity.dart';
import '../repositories/notification_repository.dart';

class GetNotificationsUseCase {
  final NotificationRepository repository;

  GetNotificationsUseCase(this.repository);

  Future<Either<Failure, List<NotificationEntity>>> execute({
    int page = 1,
    int limit = 20,
  }) {
    return repository.getNotifications(page: page, limit: limit);
  }
}

class GetUnreadCountUseCase {
  final NotificationRepository repository;

  GetUnreadCountUseCase(this.repository);

  Future<Either<Failure, int>> execute() {
    return repository.getUnreadCount();
  }
}

class MarkAsReadUseCase {
  final NotificationRepository repository;

  MarkAsReadUseCase(this.repository);

  Future<Either<Failure, bool>> execute(int id) {
    return repository.markAsRead(id);
  }
}

class MarkAllReadUseCase {
  final NotificationRepository repository;

  MarkAllReadUseCase(this.repository);

  Future<Either<Failure, bool>> execute() {
    return repository.markAllAsRead();
  }
}
