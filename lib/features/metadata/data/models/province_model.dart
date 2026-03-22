import '../../domain/entities/province_entity.dart';

class ProvinceModel extends ProvinceEntity {
  const ProvinceModel({
    required super.id,
    required super.code,
    required super.name,
  });

  factory ProvinceModel.fromJson(Map<String, dynamic> json) {
    return ProvinceModel(
      id: int.tryParse(json['code'].toString()) ?? 0,
      code: json['code'].toString(),
      name: json['name'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'code': code,
      'name': name,
    };
  }
}
