import '../../domain/entities/subscription_entity.dart';
import 'subscription_package_model.dart';

class SubscriptionModel extends SubscriptionEntity {
  SubscriptionModel({
    required super.id,
    required super.companyId,
    required super.packageId,
    required super.status,
    required super.startDate,
    required super.endDate,
    required super.usedBumpPostQuota,
    required super.dailyProcessedCount,
    super.dailyProcessedDate,
    super.lastJobPublishedAt,
    required super.headhuntingViewsUsed,
    super.headhuntingViewsResetAt,
    required super.usedFreeProceeds,
    super.proceedsResetAt,
    super.extraSlots,
    super.effectiveMaxJobs,
    super.package,
    super.slotLock,
  });

  factory SubscriptionModel.fromJson(Map<String, dynamic> json) {
    // The API returns the subscription object inside a 'subscription' key
    // and extraSlots/effectiveMaxJobs at the root level.
    final subData = json.containsKey('subscription') ? json['subscription'] : json;
    
    return SubscriptionModel(
      id: (subData['id'] as num?)?.toInt() ?? 0,
      companyId: (subData['companyId'] as num?)?.toInt() ?? 0,
      packageId: (subData['packageId'] as num?)?.toInt() ?? 0,
      status: subData['status']?.toString() ?? 'inactive',
      startDate: subData['startDate'] != null 
          ? DateTime.parse(subData['startDate'].toString()) 
          : DateTime.now(),
      endDate: subData['endDate'] != null ? DateTime.parse(subData['endDate'].toString()) : null,
      usedBumpPostQuota: (subData['usedBumpPostQuota'] as num?)?.toInt() ?? 0,
      dailyProcessedCount: (subData['dailyProcessedCount'] as num?)?.toInt() ?? 0,
      dailyProcessedDate: subData['dailyProcessedDate'] != null 
          ? DateTime.parse(subData['dailyProcessedDate'].toString()) 
          : null,
      lastJobPublishedAt: subData['lastJobPublishedAt'] != null 
          ? DateTime.parse(subData['lastJobPublishedAt'].toString()) 
          : null,
      headhuntingViewsUsed: (subData['headhuntingViewsUsed'] as num?)?.toInt() ?? 0,
      headhuntingViewsResetAt: subData['headhuntingViewsResetAt'] != null 
          ? DateTime.parse(subData['headhuntingViewsResetAt'].toString()) 
          : null,
      usedFreeProceeds: (subData['usedFreeProceeds'] as num?)?.toInt() ?? 0,
      proceedsResetAt: subData['proceedsResetAt'] != null 
          ? DateTime.parse(subData['proceedsResetAt'].toString()) 
          : null,
      extraSlots: ((json['extraSlots'] ?? subData['extraSlots'] ?? 0) as num).toInt(),
      effectiveMaxJobs: ((json['effectiveMaxJobs'] ?? subData['effectiveMaxJobs'] ?? 0) as num).toInt(),
      package: subData['package'] != null 
          ? SubscriptionPackageModel.fromJson(subData['package']) 
          : null,
      slotLock: json['slotLock'] != null ? SlotLockModel.fromJson(json['slotLock']) : null,
    );
  }
}

class SlotLockModel extends SlotLockEntity {
  SlotLockModel({
    required super.canPost,
    super.unlocksAt,
    super.blockReason,
    required super.currentActiveJobs,
    required super.currentLockedJobs,
    required super.maxActiveJobs,
    required super.slotDetails,
  });

  factory SlotLockModel.fromJson(Map<String, dynamic> json) {
    var detailsList = json['slotDetails'] as List? ?? [];
    List<SlotDetailModel> details = detailsList
        .map((e) => SlotDetailModel.fromJson(e as Map<String, dynamic>))
        .toList();

    return SlotLockModel(
      canPost: json['canPost'] as bool? ?? false,
      unlocksAt: json['unlocksAt'] != null ? DateTime.parse(json['unlocksAt'].toString()) : null,
      blockReason: json['blockReason']?.toString(),
      currentActiveJobs: (json['currentActiveJobs'] as num?)?.toInt() ?? 0,
      currentLockedJobs: (json['currentLockedJobs'] as num?)?.toInt() ?? 0,
      maxActiveJobs: (json['maxActiveJobs'] as num?)?.toInt() ?? 0,
      slotDetails: details,
    );
  }
}

class SlotDetailModel extends SlotDetailEntity {
  SlotDetailModel({
    required super.type,
    required super.slotKind,
    super.jobId,
    super.jobTitle,
    super.unlocksAt,
    super.creditSlotExpiresAt,
    super.creditSlotId,
  });

  factory SlotDetailModel.fromJson(Map<String, dynamic> json) {
    return SlotDetailModel(
      type: json['type']?.toString() ?? 'available',
      slotKind: json['slotKind']?.toString() ?? 'free',
      jobId: (json['jobId'] as num?)?.toInt(),
      jobTitle: json['jobTitle']?.toString(),
      unlocksAt: json['unlocksAt'] != null ? DateTime.parse(json['unlocksAt'].toString()) : null,
      creditSlotExpiresAt: json['creditSlotExpiresAt'] != null 
          ? DateTime.parse(json['creditSlotExpiresAt'].toString()) 
          : null,
      creditSlotId: (json['creditSlotId'] as num?)?.toInt(),
    );
  }
}

