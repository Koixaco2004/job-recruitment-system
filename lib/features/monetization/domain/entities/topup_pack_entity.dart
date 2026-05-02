import 'package:equatable/equatable.dart';

class TopupPackEntity extends Equatable {
  final int id;
  final String slug;
  final String displayName;
  final int creditBase;
  final int bonus;
  final double priceVnd;
  final bool isActive;

  const TopupPackEntity({
    required this.id,
    required this.slug,
    required this.displayName,
    required this.creditBase,
    required this.bonus,
    required this.priceVnd,
    this.isActive = true,
  });

  int get totalCredits => creditBase + bonus;

  @override
  List<Object?> get props => [id, slug, displayName, creditBase, bonus, priceVnd, isActive];
}
