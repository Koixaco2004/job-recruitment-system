import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../profile/domain/entities/skill_entity.dart';
import '../repositories/metadata_repository.dart';

class SearchSkillsUseCase {
  final MetadataRepository repository;

  SearchSkillsUseCase({required this.repository});

  Future<Either<Failure, List<SkillEntity>>> call(String query) async {
    if (query.trim().isEmpty) return const Right([]);
    return await repository.searchSkills(query);
  }
}
