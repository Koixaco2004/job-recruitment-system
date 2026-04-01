import 'package:equatable/equatable.dart';

/// Model chứa tất cả tiêu chí filter cho Job
class JobFilterModel extends Equatable {
  final String keyword; // Từ khóa tìm kiếm
  final int? provinceId; // ID tỉnh/thành phố
  final int? categoryId; // ID danh mục ngành nghề
  final int? jobTypeId; // ID hình thức làm việc

  const JobFilterModel({
    this.keyword = '',
    this.provinceId,
    this.categoryId,
    this.jobTypeId,
  });

  /// Check if any filter is active (excluding keyword usually, but for UI badge let's count)
  bool get hasActiveFilters {
    return provinceId != null ||
        categoryId != null ||
        jobTypeId != null;
  }

  /// Count active filters
  int get activeFilterCount {
    int count = 0;
    if (provinceId != null) count++;
    if (categoryId != null) count++;
    if (jobTypeId != null) count++;
    return count;
  }

  /// Copy with method
  JobFilterModel copyWith({
    String? keyword,
    int? provinceId,
    int? categoryId,
    int? jobTypeId,
  }) {
    return JobFilterModel(
      keyword: keyword ?? this.keyword,
      provinceId: provinceId ?? this.provinceId,
      categoryId: categoryId ?? this.categoryId,
      jobTypeId: jobTypeId ?? this.jobTypeId,
    );
  }

  /// Reset một trường cụ thể về null (Dùng cho copyWith khi muốn xóa lọc)
  JobFilterModel clearField({
    bool province = false,
    bool category = false,
    bool jobType = false,
  }) {
    return JobFilterModel(
      keyword: keyword,
      provinceId: province ? null : provinceId,
      categoryId: category ? null : categoryId,
      jobTypeId: jobType ? null : jobTypeId,
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
  ];
}
