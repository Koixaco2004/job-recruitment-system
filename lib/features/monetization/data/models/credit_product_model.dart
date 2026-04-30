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
      id: json['id'],
      slug: json['slug'],
      displayName: json['displayName'],
      description: json['description'],
      creditCost: json['creditCost'],
      durationDays: json['durationDays'],
      isActive: json['isActive'],
      scope: json['scope'],
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
