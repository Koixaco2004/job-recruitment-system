import 'package:equatable/equatable.dart';

class CreditProductEntity extends Equatable {
  final int id;
  final String slug;
  final String displayName;
  final String? description;
  final int creditCost;
  final int? durationDays;
  final bool isActive;
  final String scope;

  const CreditProductEntity({
    required this.id,
    required this.slug,
    required this.displayName,
    this.description,
    required this.creditCost,
    this.durationDays,
    required this.isActive,
    required this.scope,
  });

  @override
  List<Object?> get props => [
        id,
        slug,
        displayName,
        description,
        creditCost,
        durationDays,
        isActive,
        scope,
      ];
}
