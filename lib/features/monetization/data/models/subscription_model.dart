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
    );
  }
}
