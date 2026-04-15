import 'package:equatable/equatable.dart';

/// Model chứa tiêu chí filter cho việc tìm kiếm ứng viên
class CandidateFilterModel extends Equatable {
  final String keyword;
  final int? provinceId;
  final int? categoryId;
  final int? jobTypeId;
  final int? yearsOfExperience;
  final int page;

  const CandidateFilterModel({
    this.keyword = '',
    this.provinceId,
    this.categoryId,
    this.jobTypeId,
    this.yearsOfExperience,
    this.page = 1,
  });

  bool get hasActiveFilters {
    return provinceId != null ||
        categoryId != null ||
        jobTypeId != null ||
        yearsOfExperience != null;
  }

  int get activeFilterCount {
    int count = 0;
    if (provinceId != null) count++;
    if (categoryId != null) count++;
    if (jobTypeId != null) count++;
    if (yearsOfExperience != null) count++;
    return count;
  }

  CandidateFilterModel copyWith({
    String? keyword,
    int? provinceId,
    int? categoryId,
    int? jobTypeId,
    int? yearsOfExperience,
    int? page,
  }) {
    return CandidateFilterModel(
      keyword: keyword ?? this.keyword,
      provinceId: provinceId ?? this.provinceId,
      categoryId: categoryId ?? this.categoryId,
      jobTypeId: jobTypeId ?? this.jobTypeId,
      yearsOfExperience: yearsOfExperience ?? this.yearsOfExperience,
      page: page ?? this.page,
    );
  }

  CandidateFilterModel clearField({
    bool province = false,
    bool category = false,
    bool jobType = false,
    bool experience = false,
  }) {
    return CandidateFilterModel(
      keyword: keyword,
      provinceId: province ? null : provinceId,
      categoryId: category ? null : categoryId,
      jobTypeId: jobType ? null : jobTypeId,
      yearsOfExperience: experience ? null : yearsOfExperience,
      page: 1,
    );
  }

  CandidateFilterModel clear() {
    return const CandidateFilterModel();
  }

  @override
  List<Object?> get props => [
    keyword,
    provinceId,
    categoryId,
    jobTypeId,
    yearsOfExperience,
    page,
  ];
}
