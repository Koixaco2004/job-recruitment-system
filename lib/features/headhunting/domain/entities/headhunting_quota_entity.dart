import 'package:equatable/equatable.dart';

class HeadhuntingQuotaEntity extends Equatable {
  final int totalMonthlyQuota;
  final int usedThisMonth;
  final int remainingThisMonth;
  final bool canUsePremiumFilters;
  final bool freeContactUnlock;

  const HeadhuntingQuotaEntity({
    required this.totalMonthlyQuota,
    required this.usedThisMonth,
    required this.remainingThisMonth,
    required this.canUsePremiumFilters,
    required this.freeContactUnlock,
  });

  @override
  List<Object?> get props => [
        totalMonthlyQuota,
        usedThisMonth,
        remainingThisMonth,
        canUsePremiumFilters,
        freeContactUnlock,
      ];
}
