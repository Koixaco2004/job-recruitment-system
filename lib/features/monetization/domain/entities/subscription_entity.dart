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
  final int extraSlots;
  final int effectiveMaxJobs;
  final SubscriptionPackageEntity? package;
  final SlotLockEntity? slotLock;

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
    this.extraSlots = 0,
    this.effectiveMaxJobs = 0,
    this.package,
    this.slotLock,
  });

  bool get isActive => status == 'active';
  bool get isExpired => endDate != null && DateTime.now().isAfter(endDate!);
  bool get isVip => package?.isVip ?? false;
}

class SlotLockEntity {
  final bool canPost;
  final DateTime? unlocksAt;
  final String? blockReason;
  final int currentActiveJobs;
  final int currentLockedJobs;
  final int maxActiveJobs;
  final List<SlotDetailEntity> slotDetails;

  SlotLockEntity({
    required this.canPost,
    this.unlocksAt,
    this.blockReason,
    required this.currentActiveJobs,
    required this.currentLockedJobs,
    required this.maxActiveJobs,
    required this.slotDetails,
  });
}

class SlotDetailEntity {
  final String type; // 'occupied' | 'locked' | 'available'
  final String slotKind; // 'free' | 'vip' | 'credit'
  final int? jobId;
  final String? jobTitle;
  final DateTime? unlocksAt;
  final DateTime? creditSlotExpiresAt;
  final int? creditSlotId;

  SlotDetailEntity({
    required this.type,
    required this.slotKind,
    this.jobId,
    this.jobTitle,
    this.unlocksAt,
    this.creditSlotExpiresAt,
    this.creditSlotId,
  });
}

