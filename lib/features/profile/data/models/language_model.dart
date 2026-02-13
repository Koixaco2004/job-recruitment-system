import '../../domain/entities/language_entity.dart';

class LanguageModel extends LanguageEntity {
  const LanguageModel({
    super.id,
    required super.name,
    required super.proficiency,
  });

  factory LanguageModel.fromJson(Map<String, dynamic> json) {
    return LanguageModel(
      id: json['id'] as int?,
      name: json['name'] as String,
      proficiency: json['proficiency'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name, 'proficiency': proficiency};
  }
}
