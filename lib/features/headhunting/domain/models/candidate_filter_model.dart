import 'package:equatable/equatable.dart';

/// Model chứa tiêu chí filter cho việc tìm kiếm ứng viên
class CandidateFilterModel extends Equatable {
  final String keyword;
  final int? provinceId;
  final List<int>? categoryIds;
  final List<int>? skillIds;
  final int? salaryMin;
  final int? salaryMax;
  final int? minExperience;
  final int? jobTypeId;
  final String sortBy;
  final String sortOrder;
  final int page;

  const CandidateFilterModel({
    this.keyword = '',
    this.provinceId,
    this.categoryIds,
    this.skillIds,
    this.salaryMin,
    this.salaryMax,
    this.minExperience,
    this.jobTypeId,
    this.sortBy = 'createdAt',
    this.sortOrder = 'DESC',
    this.page = 1,
  });

  bool get hasActiveFilters {
    return provinceId != null ||
        categoryIds != null ||
        skillIds != null ||
        salaryMin != null ||
        salaryMax != null ||
        minExperience != null ||
        jobTypeId != null ||
        sortBy != 'createdAt' ||
        sortOrder != 'DESC';
  }

  int get activeFilterCount {
    int count = 0;
    if (provinceId != null) count++;
    if (categoryIds != null) count++;
    if (skillIds != null) count++;
    if (salaryMin != null) count++;
    if (salaryMax != null) count++;
    if (minExperience != null) count++;
    if (jobTypeId != null) count++;
    if (sortBy != 'createdAt') count++;
    if (sortOrder != 'DESC') count++;
    return count;
  }

  CandidateFilterModel copyWith({
    String? keyword,
    int? provinceId,
    List<int>? categoryIds,
    List<int>? skillIds,
    int? salaryMin,
    int? salaryMax,
    int? minExperience,
    int? jobTypeId,
    String? sortBy,
    String? sortOrder,
    int? page,
    bool? clearProvince,
    bool? clearCategory,
    bool? clearJobType,
    bool? clearExperience,
    bool? clearSalaryMin,
    bool? clearSalaryMax,
    bool? clearSkillIds,
  }) {
    return CandidateFilterModel(
      keyword: keyword ?? this.keyword,
      provinceId: clearProvince == true ? null : (provinceId ?? this.provinceId),
      categoryIds: clearCategory == true ? null : (categoryIds ?? this.categoryIds),
      skillIds: clearSkillIds == true ? null : (skillIds ?? this.skillIds),
      jobTypeId: clearJobType == true ? null : (jobTypeId ?? this.jobTypeId),
      minExperience: clearExperience == true ? null : (minExperience ?? this.minExperience),
      salaryMin: clearSalaryMin == true ? null : (salaryMin ?? this.salaryMin),
      salaryMax: clearSalaryMax == true ? null : (salaryMax ?? this.salaryMax),
      sortBy: sortBy ?? this.sortBy,
      sortOrder: sortOrder ?? this.sortOrder,
      page: page ?? this.page,
    );
  }

  CandidateFilterModel clear() {
    return const CandidateFilterModel();
  }

  @override
  List<Object?> get props => [
    keyword,
    provinceId,
    categoryIds,
    skillIds,
    salaryMin,
    salaryMax,
    minExperience,
    jobTypeId,
    sortBy,
    sortOrder,
    page,
  ];
}
