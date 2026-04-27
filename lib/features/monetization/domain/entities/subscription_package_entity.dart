import 'package:equatable/equatable.dart';

class SubscriptionPackageEntity extends Equatable {
  final int id;
  final String name;
  final String displayName;
  final double price;
  final int durationDays;
  final int maxActiveJobs;
  final int jobDurationDays;
  final int maxProfileViewsPerJob;
  final int dailyApplicationProcessLimit;
  final int bumpPostQuota;
  final int maxScreeningQuestions;
  final int monthlyHeadhuntProfileViews;
  final int monthlyFreeProceeds;
  final bool canHeadhuntSaveAndInvite;
  final bool canViewAdvancedAnalytics;
  final bool canHideSalary;
  final bool canRequireCv;
  final bool hasVipBadge;
  final bool canUsePremiumFilters;
  final bool freeContactUnlock;
  final bool freeAiScoring;

  const SubscriptionPackageEntity({
    required this.id,
    required this.name,
    required this.displayName,
    required this.price,
    required this.durationDays,
    required this.maxActiveJobs,
    required this.jobDurationDays,
    required this.maxProfileViewsPerJob,
    required this.dailyApplicationProcessLimit,
    required this.bumpPostQuota,
    required this.maxScreeningQuestions,
    required this.monthlyHeadhuntProfileViews,
    required this.monthlyFreeProceeds,
    required this.canHeadhuntSaveAndInvite,
    required this.canViewAdvancedAnalytics,
    required this.canHideSalary,
    required this.canRequireCv,
    required this.hasVipBadge,
    required this.canUsePremiumFilters,
    required this.freeContactUnlock,
    required this.freeAiScoring,
  });

  bool get isFree => price == 0;
  bool get isVip => name.toLowerCase() == 'vip' || price > 0;

  @override
  List<Object?> get props => [
        id,
        name,
        displayName,
        price,
        durationDays,
        maxActiveJobs,
        jobDurationDays,
        maxProfileViewsPerJob,
        dailyApplicationProcessLimit,
        bumpPostQuota,
        maxScreeningQuestions,
        monthlyHeadhuntProfileViews,
        monthlyFreeProceeds,
        canHeadhuntSaveAndInvite,
        canViewAdvancedAnalytics,
        canHideSalary,
        canRequireCv,
        hasVipBadge,
        canUsePremiumFilters,
        freeContactUnlock,
        freeAiScoring,
      ];
}
