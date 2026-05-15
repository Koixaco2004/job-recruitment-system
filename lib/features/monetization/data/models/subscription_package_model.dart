import '../../domain/entities/subscription_package_entity.dart';

class SubscriptionPackageModel extends SubscriptionPackageEntity {
  const SubscriptionPackageModel({
    required super.id,
    required super.name,
    required super.displayName,
    required super.price,
    required super.durationDays,
    required super.maxActiveJobs,
    required super.jobDurationDays,
    required super.maxProfileViewsPerJob,
    required super.dailyApplicationProcessLimit,
    required super.bumpPostQuota,
    required super.maxScreeningQuestions,
    required super.monthlyHeadhuntProfileViews,
    required super.monthlyFreeProceeds,
    required super.canHeadhuntSaveAndInvite,
    required super.canViewAdvancedAnalytics,
    required super.canHideSalary,
    required super.canRequireCv,
    required super.hasVipBadge,
    required super.canUsePremiumFilters,
    required super.freeContactUnlock,
    required super.freeAiScoring,
  });

  factory SubscriptionPackageModel.fromJson(Map<String, dynamic> json) {
    return SubscriptionPackageModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      name: json['name']?.toString() ?? '',
      displayName: json['displayName']?.toString() ?? '',
      price: double.tryParse(json['price']?.toString() ?? '0') ?? 0.0,
      durationDays: (json['durationDays'] as num?)?.toInt() ?? 0,
      maxActiveJobs: (json['maxActiveJobs'] as num?)?.toInt() ?? 0,
      jobDurationDays: (json['jobDurationDays'] as num?)?.toInt() ?? 0,
      maxProfileViewsPerJob: (json['maxProfileViewsPerJob'] as num?)?.toInt() ?? 0,
      dailyApplicationProcessLimit: (json['dailyApplicationProcessLimit'] as num?)?.toInt() ?? 0,
      bumpPostQuota: (json['bumpPostQuota'] as num?)?.toInt() ?? 0,
      maxScreeningQuestions: (json['maxScreeningQuestions'] as num?)?.toInt() ?? 0,
      monthlyHeadhuntProfileViews: (json['monthlyHeadhuntProfileViews'] as num?)?.toInt() ?? 0,
      monthlyFreeProceeds: (json['monthlyFreeProceeds'] as num?)?.toInt() ?? 0,
      canHeadhuntSaveAndInvite: json['canHeadhuntSaveAndInvite'] as bool? ?? false,
      canViewAdvancedAnalytics: json['canViewAdvancedAnalytics'] as bool? ?? false,
      canHideSalary: json['canHideSalary'] as bool? ?? false,
      canRequireCv: json['canRequireCv'] as bool? ?? false,
      hasVipBadge: json['hasVipBadge'] as bool? ?? false,
      canUsePremiumFilters: json['canUsePremiumFilters'] as bool? ?? false,
      freeContactUnlock: json['freeContactUnlock'] as bool? ?? false,
      freeAiScoring: json['freeAiScoring'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'displayName': displayName,
      'price': price,
      'durationDays': durationDays,
      'maxActiveJobs': maxActiveJobs,
      'jobDurationDays': jobDurationDays,
      'maxProfileViewsPerJob': maxProfileViewsPerJob,
      'dailyApplicationProcessLimit': dailyApplicationProcessLimit,
      'bumpPostQuota': bumpPostQuota,
      'maxScreeningQuestions': maxScreeningQuestions,
      'monthlyHeadhuntProfileViews': monthlyHeadhuntProfileViews,
      'monthlyFreeProceeds': monthlyFreeProceeds,
      'canHeadhuntSaveAndInvite': canHeadhuntSaveAndInvite,
      'canViewAdvancedAnalytics': canViewAdvancedAnalytics,
      'canHideSalary': canHideSalary,
      'canRequireCv': canRequireCv,
      'hasVipBadge': hasVipBadge,
      'canUsePremiumFilters': canUsePremiumFilters,
      'freeContactUnlock': freeContactUnlock,
      'freeAiScoring': freeAiScoring,
    };
  }
}
