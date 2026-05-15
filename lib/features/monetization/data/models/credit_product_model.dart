import '../../domain/entities/credit_product_entity.dart';

class CreditProductModel extends CreditProductEntity {
  const CreditProductModel({
    required int id,
    required String slug,
    required String displayName,
    String? description,
    required int creditCost,
    int? durationDays,
    required bool isActive,
    required String scope,
  }) : super(
          id: id,
          slug: slug,
          displayName: displayName,
          description: description,
          creditCost: creditCost,
          durationDays: durationDays,
          isActive: isActive,
          scope: scope,
        );

  factory CreditProductModel.fromJson(Map<String, dynamic> json) {
    return CreditProductModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      slug: json['slug']?.toString() ?? '',
      displayName: json['displayName']?.toString() ?? '',
      description: json['description']?.toString(),
      creditCost: (json['creditCost'] as num?)?.toInt() ?? 0,
      durationDays: (json['durationDays'] as num?)?.toInt(),
      isActive: json['isActive'] as bool? ?? true,
      scope: json['scope']?.toString() ?? 'global',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'slug': slug,
      'displayName': displayName,
      'description': description,
      'creditCost': creditCost,
      'durationDays': durationDays,
      'isActive': isActive,
      'scope': scope,
    };
  }
}
