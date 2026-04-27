import 'package:equatable/equatable.dart';

class TopupPackEntity extends Equatable {
  final String id;
  final int creditBase;
  final int bonus;
  final double priceVnd;

  const TopupPackEntity({
    required this.id,
    required this.creditBase,
    required this.bonus,
    required this.priceVnd,
  });

  int get totalCredits => creditBase + bonus;

  @override
  List<Object?> get props => [id, creditBase, bonus, priceVnd];
}
