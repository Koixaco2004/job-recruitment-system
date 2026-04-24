import 'package:equatable/equatable.dart';

/// Model chứa tất cả tiêu chí filter cho Job
class JobFilterModel extends Equatable {
  final String keyword; // Từ khóa tìm kiếm
  final int? provinceId; // ID tỉnh/thành phố
  final int? categoryId; // ID danh mục ngành nghề
  final int? jobTypeId; // ID hình thức làm việc
  final int? levelId; // ID cấp bậc
  final int? salaryMin; // Lương tối thiểu
  final int? salaryMax; // Lương tối đa
  final String? requiredDegree; // Yêu cầu bằng cấp
  final int? maxYearsRequired; // Số năm kinh nghiệm tối đa
  final List<int>? skillIds; // Danh sách ID kỹ năng
  final String sortBy;
  final String sortOrder;
  final int page;

  const JobFilterModel({
    this.keyword = '',
    this.provinceId,
    this.categoryId,
    this.jobTypeId,
    this.levelId,
    this.salaryMin,
    this.salaryMax,
    this.requiredDegree,
    this.maxYearsRequired,
    this.skillIds,
    this.sortBy = 'createdAt',
    this.sortOrder = 'DESC',
    this.page = 1,
  });

  /// Check if any filter is active (excluding keyword usually, but for UI badge let's count)
  bool get hasActiveFilters {
    return provinceId != null ||
        categoryId != null ||
        jobTypeId != null ||
        levelId != null ||
        salaryMin != null ||
        salaryMax != null ||
        requiredDegree != null ||
        maxYearsRequired != null ||
        (skillIds != null && skillIds!.isNotEmpty) ||
        sortBy != 'createdAt' ||
        sortOrder != 'DESC' ||
        page != 1;
  }

  /// Count active filters
  int get activeFilterCount {
    int count = 0;
    if (provinceId != null) count++;
    if (categoryId != null) count++;
    if (jobTypeId != null) count++;
    if (levelId != null) count++;
    if (salaryMin != null) count++;
    if (salaryMax != null) count++;
    if (requiredDegree != null) count++;
    if (maxYearsRequired != null) count++;
    if (skillIds != null && skillIds!.isNotEmpty) count++;
    if (sortBy != 'createdAt') count++;
    if (sortOrder != 'DESC') count++;
    if (page != 1) count++;
    return count;
  }

  /// Reset một trường cụ thể về null
  JobFilterModel clearField({
    bool province = false,
    bool category = false,
    bool jobType = false,
    bool level = false,
    bool salaryMin = false,
    bool salaryMax = false,
    bool requiredDegree = false,
    bool maxYearsRequired = false,
    bool skills = false,
  }) {
    return JobFilterModel(
      keyword: keyword,
      provinceId: province ? null : provinceId,
      categoryId: category ? null : categoryId,
      jobTypeId: jobType ? null : jobTypeId,
      levelId: level ? null : levelId,
      salaryMin: salaryMin ? null : this.salaryMin,
      salaryMax: salaryMax ? null : this.salaryMax,
      requiredDegree: requiredDegree ? null : this.requiredDegree,
      maxYearsRequired: maxYearsRequired ? null : this.maxYearsRequired,
      skillIds: skills ? null : this.skillIds,
      sortBy: sortBy,
      sortOrder: sortOrder,
      page: page,
    );
  }

  /// Copy with method supporting null values via special logic if needed
  /// For simplicity in this case, we can use clearField for nulls or update copyWith
  JobFilterModel copyWith({
    String? keyword,
    int? provinceId,
    int? categoryId,
    int? jobTypeId,
    int? levelId,
    int? salaryMin,
    int? salaryMax,
    String? requiredDegree,
    int? maxYearsRequired,
    List<int>? skillIds,
    String? sortBy,
    String? sortOrder,
    int? page,
    bool? clearProvince,
    bool? clearCategory,
    bool? clearJobType,
    bool? clearLevel,
    bool? clearSalaryMin,
    bool? clearSalaryMax,
    bool? clearRequiredDegree,
    bool? clearMaxYearsRequired,
    bool? clearSkillIds,
  }) {
    return JobFilterModel(
      keyword: keyword ?? this.keyword,
      provinceId: clearProvince == true ? null : (provinceId ?? this.provinceId),
      categoryId: clearCategory == true ? null : (categoryId ?? this.categoryId),
      jobTypeId: clearJobType == true ? null : (jobTypeId ?? this.jobTypeId),
      levelId: clearLevel == true ? null : (levelId ?? this.levelId),
      salaryMin: clearSalaryMin == true ? null : (salaryMin ?? this.salaryMin),
      salaryMax: clearSalaryMax == true ? null : (salaryMax ?? this.salaryMax),
      requiredDegree: clearRequiredDegree == true ? null : (requiredDegree ?? this.requiredDegree),
      maxYearsRequired: clearMaxYearsRequired == true ? null : (maxYearsRequired ?? this.maxYearsRequired),
      skillIds: clearSkillIds == true ? null : (skillIds ?? this.skillIds),
      sortBy: sortBy ?? this.sortBy,
      sortOrder: sortOrder ?? this.sortOrder,
      page: page ?? this.page,
    );
  }

  /// Clear all filters
  JobFilterModel clear() {
    return const JobFilterModel();
  }

  @override
  List<Object?> get props => [
    keyword,
    provinceId,
    categoryId,
    jobTypeId,
    levelId,
    salaryMin,
    salaryMax,
    requiredDegree,
    maxYearsRequired,
    skillIds,
    sortBy,
    sortOrder,
    page,
  ];
}
