import 'subscription_package_entity.dart';

class SubscriptionEntity {
  final int id;
  final int companyId;
  final int packageId;
  final String status;
  final DateTime startDate;
  final DateTime? endDate;
  final int usedBumpPostQuota;
  final int dailyProcessedCount;
  final DateTime? dailyProcessedDate;
  final DateTime? lastJobPublishedAt;
  final int headhuntingViewsUsed;
  final DateTime? headhuntingViewsResetAt;
  final int usedFreeProceeds;
  final DateTime? proceedsResetAt;
  final SubscriptionPackageEntity? package;

  SubscriptionEntity({
    required this.id,
    required this.companyId,
    required this.packageId,
    required this.status,
    required this.startDate,
    this.endDate,
    required this.usedBumpPostQuota,
    required this.dailyProcessedCount,
    this.dailyProcessedDate,
    this.lastJobPublishedAt,
    required this.headhuntingViewsUsed,
    this.headhuntingViewsResetAt,
    required this.usedFreeProceeds,
    this.proceedsResetAt,
    this.package,
  });

  bool get isActive => status == 'active';
  bool get isExpired => endDate != null && DateTime.now().isAfter(endDate!);
  bool get isVip => package?.isVip ?? false;
}
