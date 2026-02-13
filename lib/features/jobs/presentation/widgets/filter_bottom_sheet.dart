import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../domain/models/job_filter_model.dart';
import '../providers/job_provider.dart';

/// Bottom sheet cho bộ lọc nâng cao
class FilterBottomSheet extends StatefulWidget {
  const FilterBottomSheet({super.key});

  @override
  State<FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<FilterBottomSheet> {
  late JobFilterModel _tempFilter;

  @override
  void initState() {
    super.initState();
    // Copy current filter
    _tempFilter = context.read<JobProvider>().filter;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(20),
              ),
            ),
            child: Row(
              children: [
                const Text(
                  'Bộ lọc nâng cao',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),

          // Filter content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildCityFilter(),
                  const SizedBox(height: 24),
                  _buildSalaryFilter(),
                  const SizedBox(height: 24),
                  _buildJobTypeFilter(),
                  const SizedBox(height: 24),
                  _buildJobLevelFilter(),
                  const SizedBox(height: 24),
                  _buildEducationFilter(),
                  const SizedBox(height: 24),
                  _buildIndustryFilter(),
                  const SizedBox(height: 80), // Space for buttons
                ],
              ),
            ),
          ),

          // Bottom buttons
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withValues(alpha: 0.2),
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      setState(() {
                        _tempFilter = const JobFilterModel();
                      });
                    },
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: const Text('Xóa bộ lọc'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: ElevatedButton(
                    onPressed: () {
                      context.read<JobProvider>().updateFilter(_tempFilter);
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      backgroundColor: Theme.of(context).primaryColor,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Áp dụng'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: Colors.black87,
      ),
    );
  }

  Widget _buildCityFilter() {
    final cities = ['Hà Nội', 'Hồ Chí Minh', 'Đà Nẵng', 'Remote', 'Khác'];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Địa điểm'),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: cities.map((city) {
            final isSelected = _tempFilter.cities.contains(city);
            return FilterChip(
              label: Text(city),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  final newCities = List<String>.from(_tempFilter.cities);
                  if (selected) {
                    newCities.add(city);
                  } else {
                    newCities.remove(city);
                  }
                  _tempFilter = _tempFilter.copyWith(cities: newCities);
                });
              },
              selectedColor: Theme.of(
                context,
              ).primaryColor.withValues(alpha: 0.2),
              checkmarkColor: Theme.of(context).primaryColor,
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildSalaryFilter() {
    final salaryRanges = {
      SalaryRange.all: 'Tất cả',
      SalaryRange.under10: '< 10 triệu',
      SalaryRange.from10To20: '10-20 triệu',
      SalaryRange.from20To50: '20-50 triệu',
      SalaryRange.above50: '> 50 triệu',
      SalaryRange.negotiable: 'Thỏa thuận',
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Mức lương'),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: salaryRanges.entries.map((entry) {
            final isSelected = _tempFilter.salaryRange == entry.key;
            return ChoiceChip(
              label: Text(entry.value),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  _tempFilter = _tempFilter.copyWith(salaryRange: entry.key);
                });
              },
              selectedColor: Theme.of(
                context,
              ).primaryColor.withValues(alpha: 0.2),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildJobTypeFilter() {
    final jobTypes = {
      'fulltime': 'Full-time',
      'parttime': 'Part-time',
      'remote': 'Remote',
      'freelance': 'Freelance',
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Hình thức làm việc'),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: jobTypes.entries.map((entry) {
            final isSelected = _tempFilter.jobTypes.contains(entry.key);
            return FilterChip(
              label: Text(entry.value),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  final newTypes = List<String>.from(_tempFilter.jobTypes);
                  if (selected) {
                    newTypes.add(entry.key);
                  } else {
                    newTypes.remove(entry.key);
                  }
                  _tempFilter = _tempFilter.copyWith(jobTypes: newTypes);
                });
              },
              selectedColor: Theme.of(
                context,
              ).primaryColor.withValues(alpha: 0.2),
              checkmarkColor: Theme.of(context).primaryColor,
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildJobLevelFilter() {
    final jobLevels = {
      'intern': 'Thực tập',
      'fresher': 'Fresher',
      'junior': 'Junior',
      'middle': 'Middle',
      'senior': 'Senior',
      'leader': 'Leader',
      'manager': 'Manager',
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Cấp bậc'),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: jobLevels.entries.map((entry) {
            final isSelected = _tempFilter.jobLevels.contains(entry.key);
            return FilterChip(
              label: Text(entry.value),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  final newLevels = List<String>.from(_tempFilter.jobLevels);
                  if (selected) {
                    newLevels.add(entry.key);
                  } else {
                    newLevels.remove(entry.key);
                  }
                  _tempFilter = _tempFilter.copyWith(jobLevels: newLevels);
                });
              },
              selectedColor: Theme.of(
                context,
              ).primaryColor.withValues(alpha: 0.2),
              checkmarkColor: Theme.of(context).primaryColor,
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildEducationFilter() {
    final educationLevels = ['Đại học', 'Cao đẳng', 'Thạc sĩ', 'Không yêu cầu'];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Trình độ học vấn'),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: educationLevels.map((level) {
            final isSelected = _tempFilter.educationLevels.contains(level);
            return FilterChip(
              label: Text(level),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  final newLevels = List<String>.from(
                    _tempFilter.educationLevels,
                  );
                  if (selected) {
                    newLevels.add(level);
                  } else {
                    newLevels.remove(level);
                  }
                  _tempFilter = _tempFilter.copyWith(
                    educationLevels: newLevels,
                  );
                });
              },
              selectedColor: Theme.of(
                context,
              ).primaryColor.withValues(alpha: 0.2),
              checkmarkColor: Theme.of(context).primaryColor,
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildIndustryFilter() {
    final industries = [
      'Công nghệ thông tin',
      'Fintech',
      'Thương mại điện tử',
      'Công nghệ - Logistics',
      'Ngân hàng - Tài chính',
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Ngành nghề'),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: industries.map((industry) {
            final isSelected = _tempFilter.industries.contains(industry);
            return FilterChip(
              label: Text(industry),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  final newIndustries = List<String>.from(
                    _tempFilter.industries,
                  );
                  if (selected) {
                    newIndustries.add(industry);
                  } else {
                    newIndustries.remove(industry);
                  }
                  _tempFilter = _tempFilter.copyWith(industries: newIndustries);
                });
              },
              selectedColor: Theme.of(
                context,
              ).primaryColor.withValues(alpha: 0.2),
              checkmarkColor: Theme.of(context).primaryColor,
            );
          }).toList(),
        ),
      ],
    );
  }
}
