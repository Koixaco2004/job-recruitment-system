import '../../domain/entities/topup_pack_entity.dart';

class TopupPackModel extends TopupPackEntity {
  const TopupPackModel({
    required super.id,
    required super.creditBase,
    required super.bonus,
    required super.priceVnd,
  });

  factory TopupPackModel.fromJson(Map<String, dynamic> json) {
    return TopupPackModel(
      id: json['id'] as String? ?? '',
      creditBase: json['creditBase'] as int? ?? 0,
      bonus: json['bonus'] as int? ?? 0,
      priceVnd: double.tryParse(json['priceVnd'].toString()) ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'creditBase': creditBase,
      'bonus': bonus,
      'priceVnd': priceVnd,
    };
  }
}
