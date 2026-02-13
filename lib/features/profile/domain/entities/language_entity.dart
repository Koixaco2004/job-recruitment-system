import 'package:equatable/equatable.dart';

/// Entity cho ngoại ngữ
class LanguageEntity extends Equatable {
  final int? id;
  final String name;
  final String proficiency; // 'Sơ cấp', 'Trung cấp', 'Cao cấp', 'Bản ngữ'

  const LanguageEntity({
    this.id,
    required this.name,
    required this.proficiency,
  });

  @override
  List<Object?> get props => [id, name, proficiency];
}
