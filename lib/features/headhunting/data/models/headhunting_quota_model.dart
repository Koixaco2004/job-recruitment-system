import '../../domain/entities/headhunting_quota_entity.dart';

class HeadhuntingQuotaModel extends HeadhuntingQuotaEntity {
  const HeadhuntingQuotaModel({
    required super.totalMonthlyQuota,
    required super.usedThisMonth,
    required super.remainingThisMonth,
    required super.canUsePremiumFilters,
    required super.freeContactUnlock,
  });

  factory HeadhuntingQuotaModel.fromJson(Map<String, dynamic> json) {
    return HeadhuntingQuotaModel(
      totalMonthlyQuota: json['totalMonthlyQuota'] as int? ?? 0,
      usedThisMonth: json['usedThisMonth'] as int? ?? 0,
      remainingThisMonth: json['remainingThisMonth'] as int? ?? 0,
      canUsePremiumFilters: json['canUsePremiumFilters'] as bool? ?? false,
      freeContactUnlock: json['freeContactUnlock'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalMonthlyQuota': totalMonthlyQuota,
      'usedThisMonth': usedThisMonth,
      'remainingThisMonth': remainingThisMonth,
      'canUsePremiumFilters': canUsePremiumFilters,
      'freeContactUnlock': freeContactUnlock,
    };
  }
}
