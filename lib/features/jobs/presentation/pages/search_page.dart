import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/job_provider.dart';
import '../../../profile/data/models/job_category_model.dart';
import '../../../profile/presentation/providers/profile_provider.dart';
import '../widgets/filter_bottom_sheet.dart';
import '../widgets/job_card.dart';
import 'job_detail_page.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    // Initialize with current keyword
    _searchController.text = context.read<JobProvider>().filter.keyword;
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      final provider = context.read<JobProvider>();
      if (!provider.isLoading && provider.hasMoreJobs) {
        provider.fetchJobs(refresh: false);
      }
    }
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
                  controller: _scrollController,
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.only(top: 8, bottom: 16),
                  itemCount: provider.jobs.length + (provider.hasMoreJobs ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index == provider.jobs.length) {
                      return const Center(
                        child: Padding(
                          padding: EdgeInsets.all(16),
                          child: CircularProgressIndicator(),
                        ),
                      );
                    }
                    final job = provider.jobs[index];
                    return JobCard(
                      job: job,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => JobDetailPage(job: job),
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
    final profileProvider = context.read<ProfileProvider>();

    // Province
    if (filter.provinceId != null) {
      final name = profileProvider.getProvinceName(filter.provinceId);
      if (name != null) {
        chips.add(
          _buildFilterChip(name, () {
            provider.updateFilter(filter.clearField(province: true));
          }),
        );
      }
    }

    // Category
    if (filter.categoryId != null) {
      final category = profileProvider.allJobCategories.firstWhere(
        (c) => c.id == filter.categoryId,
        orElse: () => const JobCategoryModel(id: -1, name: ''),
      );
      if (category.id != -1) {
        chips.add(
          _buildFilterChip(category.name, () {
            provider.updateFilter(filter.clearField(category: true));
          }),
        );
      }
    }

    // Job Type
    if (filter.jobTypeId != null) {
      final name = profileProvider.getJobTypeName(filter.jobTypeId);
      if (name != null) {
        chips.add(
          _buildFilterChip(name, () {
            provider.updateFilter(filter.clearField(jobType: true));
          }),
        );
      }
    }

    return chips;
  }

  Widget _buildFilterChip(String label, VoidCallback onDeleted) {
    return Chip(
      label: Text(label, style: const TextStyle(fontSize: 12)),
      onDeleted: onDeleted,
      deleteIcon: const Icon(Icons.close, size: 14),
      backgroundColor: Colors.blue.withValues(alpha: 0.1),
      side: BorderSide.none,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      visualDensity: VisualDensity.compact,
    );
  }
}
