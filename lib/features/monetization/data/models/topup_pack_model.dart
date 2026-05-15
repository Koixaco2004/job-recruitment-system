import '../../domain/entities/topup_pack_entity.dart';

class TopupPackModel extends TopupPackEntity {
  const TopupPackModel({
    required super.id,
    required super.slug,
    required super.displayName,
    required super.creditBase,
    required super.bonus,
    required super.priceVnd,
    super.isActive,
  });

  factory TopupPackModel.fromJson(Map<String, dynamic> json) {
    return TopupPackModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      slug: json['slug']?.toString() ?? '',
      displayName: json['displayName']?.toString() ?? '',
      creditBase: (json['creditBase'] as num?)?.toInt() ?? 0,
      bonus: (json['bonus'] as num?)?.toInt() ?? 0,
      priceVnd: double.tryParse(json['priceVnd']?.toString() ?? '0') ?? 0.0,
      isActive: json['isActive'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'slug': slug,
      'displayName': displayName,
      'creditBase': creditBase,
      'bonus': bonus,
      'priceVnd': priceVnd,
      'isActive': isActive,
    };
  }
}
