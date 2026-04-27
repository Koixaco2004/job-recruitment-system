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
    super.package,
  });

  factory SubscriptionModel.fromJson(Map<String, dynamic> json) {
    // The API might return the subscription object inside a 'subscription' key or directly
    final subData = json.containsKey('subscription') ? json['subscription'] : json;
    
    return SubscriptionModel(
      id: subData['id'],
      companyId: subData['companyId'],
      packageId: subData['packageId'],
      status: subData['status'],
      startDate: DateTime.parse(subData['startDate']),
      endDate: subData['endDate'] != null ? DateTime.parse(subData['endDate']) : null,
      usedBumpPostQuota: subData['usedBumpPostQuota'] ?? 0,
      dailyProcessedCount: subData['dailyProcessedCount'] ?? 0,
      dailyProcessedDate: subData['dailyProcessedDate'] != null 
          ? DateTime.parse(subData['dailyProcessedDate']) 
          : null,
      lastJobPublishedAt: subData['lastJobPublishedAt'] != null 
          ? DateTime.parse(subData['lastJobPublishedAt']) 
          : null,
      headhuntingViewsUsed: subData['headhuntingViewsUsed'] ?? 0,
      headhuntingViewsResetAt: subData['headhuntingViewsResetAt'] != null 
          ? DateTime.parse(subData['headhuntingViewsResetAt']) 
          : null,
      usedFreeProceeds: subData['usedFreeProceeds'] ?? 0,
      proceedsResetAt: subData['proceedsResetAt'] != null 
          ? DateTime.parse(subData['proceedsResetAt']) 
          : null,
      package: subData['package'] != null 
          ? SubscriptionPackageModel.fromJson(subData['package']) 
          : null,
    );
  }
}
