import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../domain/models/job_filter_model.dart';
import '../providers/job_provider.dart';
import '../widgets/filter_bottom_sheet.dart';
import '../widgets/job_card.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Initialize with current keyword
    _searchController.text = context.read<JobProvider>().filter.keyword;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String keyword) {
    final provider = context.read<JobProvider>();
    provider.updateFilter(provider.filter.copyWith(keyword: keyword));
  }

  void _clearSearch() {
    _searchController.clear();
    _onSearchChanged('');
  }

  void _showFilterBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const FilterBottomSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text(
          'Tìm kiếm việc làm',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Search bar + Filter button
          Container(
            color: Theme.of(context).primaryColor,
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    onChanged: _onSearchChanged,
                    decoration: InputDecoration(
                      hintText: 'Tìm theo tên việc làm, công ty...',
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: _clearSearch,
                            )
                          : null,
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Consumer<JobProvider>(
                  builder: (context, provider, child) {
                    final filterCount = provider.filter.activeFilterCount;
                    return Stack(
                      children: [
                        IconButton(
                          onPressed: _showFilterBottomSheet,
                          icon: const Icon(Icons.filter_list),
                          style: IconButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: Theme.of(context).primaryColor,
                            padding: const EdgeInsets.all(12),
                          ),
                        ),
                        if (filterCount > 0)
                          Positioned(
                            right: 0,
                            top: 0,
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: const BoxDecoration(
                                color: Colors.red,
                                shape: BoxShape.circle,
                              ),
                              constraints: const BoxConstraints(
                                minWidth: 20,
                                minHeight: 20,
                              ),
                              child: Text(
                                '$filterCount',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),

          // Active filter chips
          Consumer<JobProvider>(
            builder: (context, provider, child) {
              if (!provider.filter.hasActiveFilters) {
                return const SizedBox.shrink();
              }

              return Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                color: Colors.white,
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    ..._buildActiveFilterChips(provider),
                    if (provider.filter.hasActiveFilters)
                      ActionChip(
                        label: const Text('Xóa tất cả'),
                        onPressed: () {
                          provider.clearFilter();
                          _searchController.clear();
                        },
                        avatar: const Icon(Icons.clear_all, size: 16),
                      ),
                  ],
                ),
              );
            },
          ),

          // Results count
          Consumer<JobProvider>(
            builder: (context, provider, child) {
              return Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                color: Colors.white,
                child: Text(
                  'Tìm thấy ${provider.jobs.length} việc làm',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
              );
            },
          ),

          // Job list
          Expanded(
            child: Consumer<JobProvider>(
              builder: (context, provider, child) {
                if (provider.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!provider.hasJobs) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.search_off,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Không tìm thấy việc làm phù hợp',
                          style: TextStyle(color: Colors.grey, fontSize: 16),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Thử thay đổi bộ lọc hoặc từ khóa tìm kiếm',
                          style: TextStyle(color: Colors.grey, fontSize: 14),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.only(top: 8, bottom: 16),
                  itemCount: provider.jobs.length,
                  itemBuilder: (context, index) {
                    final job = provider.jobs[index];
                    return JobCard(
                      job: job,
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Xem chi tiết: ${job.title}'),
                            duration: const Duration(seconds: 1),
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildActiveFilterChips(JobProvider provider) {
    final chips = <Widget>[];
    final filter = provider.filter;

    // Cities
    for (final city in filter.cities) {
      chips.add(
        Chip(
          label: Text(city),
          onDeleted: () {
            final newCities = List<String>.from(filter.cities)..remove(city);
            provider.updateFilter(filter.copyWith(cities: newCities));
          },
          deleteIcon: const Icon(Icons.close, size: 16),
        ),
      );
    }

    // Salary range
    if (filter.salaryRange != SalaryRange.all) {
      final salaryLabels = {
        SalaryRange.under10: '< 10tr',
        SalaryRange.from10To20: '10-20tr',
        SalaryRange.from20To50: '20-50tr',
        SalaryRange.above50: '> 50tr',
        SalaryRange.negotiable: 'Thỏa thuận',
      };
      chips.add(
        Chip(
          label: Text(salaryLabels[filter.salaryRange] ?? ''),
          onDeleted: () {
            provider.updateFilter(
              filter.copyWith(salaryRange: SalaryRange.all),
            );
          },
          deleteIcon: const Icon(Icons.close, size: 16),
        ),
      );
    }

    // Job types
    for (final type in filter.jobTypes) {
      final typeLabels = {
        'fulltime': 'Full-time',
        'parttime': 'Part-time',
        'remote': 'Remote',
        'freelance': 'Freelance',
      };
      chips.add(
        Chip(
          label: Text(typeLabels[type] ?? type),
          onDeleted: () {
            final newTypes = List<String>.from(filter.jobTypes)..remove(type);
            provider.updateFilter(filter.copyWith(jobTypes: newTypes));
          },
          deleteIcon: const Icon(Icons.close, size: 16),
        ),
      );
    }

    // Job levels
    for (final level in filter.jobLevels) {
      chips.add(
        Chip(
          label: Text(level),
          onDeleted: () {
            final newLevels = List<String>.from(filter.jobLevels)
              ..remove(level);
            provider.updateFilter(filter.copyWith(jobLevels: newLevels));
          },
          deleteIcon: const Icon(Icons.close, size: 16),
        ),
      );
    }

    return chips;
  }
}
