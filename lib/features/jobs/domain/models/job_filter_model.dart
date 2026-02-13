import 'package:equatable/equatable.dart';

/// Enum cho khoảng lương
enum SalaryRange {
  all, // Tất cả
  under10, // < 10 triệu
  from10To20, // 10-20 triệu
  from20To50, // 20-50 triệu
  above50, // > 50 triệu
  negotiable, // Thỏa thuận
}

/// Model chứa tất cả tiêu chí filter
class JobFilterModel extends Equatable {
  final String keyword; // Từ khóa tìm kiếm
  final List<String> cities; // Danh sách thành phố
  final SalaryRange salaryRange; // Khoảng lương
  final List<String> jobTypes; // Hình thức làm việc
  final List<String> jobLevels; // Cấp bậc
  final List<String> educationLevels; // Trình độ học vấn
  final List<String> industries; // Ngành nghề

  const JobFilterModel({
    this.keyword = '',
    this.cities = const [],
    this.salaryRange = SalaryRange.all,
    this.jobTypes = const [],
    this.jobLevels = const [],
    this.educationLevels = const [],
    this.industries = const [],
  });

  /// Check if any filter is active
  bool get hasActiveFilters {
    return keyword.isNotEmpty ||
        cities.isNotEmpty ||
        salaryRange != SalaryRange.all ||
        jobTypes.isNotEmpty ||
        jobLevels.isNotEmpty ||
        educationLevels.isNotEmpty ||
        industries.isNotEmpty;
  }

  /// Count active filters (excluding keyword)
  int get activeFilterCount {
    int count = 0;
    if (cities.isNotEmpty) count++;
    if (salaryRange != SalaryRange.all) count++;
    if (jobTypes.isNotEmpty) count++;
    if (jobLevels.isNotEmpty) count++;
    if (educationLevels.isNotEmpty) count++;
    if (industries.isNotEmpty) count++;
    return count;
  }

  /// Copy with method
  JobFilterModel copyWith({
    String? keyword,
    List<String>? cities,
    SalaryRange? salaryRange,
    List<String>? jobTypes,
    List<String>? jobLevels,
    List<String>? educationLevels,
    List<String>? industries,
  }) {
    return JobFilterModel(
      keyword: keyword ?? this.keyword,
      cities: cities ?? this.cities,
      salaryRange: salaryRange ?? this.salaryRange,
      jobTypes: jobTypes ?? this.jobTypes,
      jobLevels: jobLevels ?? this.jobLevels,
      educationLevels: educationLevels ?? this.educationLevels,
      industries: industries ?? this.industries,
    );
  }

  /// Clear all filters
  JobFilterModel clear() {
    return const JobFilterModel();
  }

  @override
  List<Object?> get props => [
    keyword,
    cities,
    salaryRange,
    jobTypes,
    jobLevels,
    educationLevels,
    industries,
  ];
}
