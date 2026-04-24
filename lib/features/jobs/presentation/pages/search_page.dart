import 'dart:async';
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
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    // Initialize with current keyword
    _searchController.text = context.read<JobProvider>().filter.keyword;
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _debounce?.cancel();
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
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      final provider = context.read<JobProvider>();
      provider.updateFilter(provider.filter.copyWith(keyword: keyword));
    });
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
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      body: Column(
        children: [
          // Search bar
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: TextField(
              controller: _searchController,
              onChanged: _onSearchChanged,
              maxLength: 100,
              decoration: InputDecoration(
                hintText: 'Tìm theo tên việc làm, công ty...',
                prefixIcon: const Icon(Icons.search),
                counterText: '', // Hide counter
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: _clearSearch,
                      )
                    : null,
                filled: true,
                fillColor: Colors.grey[100],
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

          // Filter Bar
          Consumer2<JobProvider, ProfileProvider>(
            builder: (context, jobProvider, profileProvider, child) {
              return _buildFilterBar(jobProvider, profileProvider);
            },
          ),

          // Results count
          Consumer<JobProvider>(
            builder: (context, provider, child) {
              return Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                        color: Colors.blue,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Tìm thấy ${provider.jobs.length} việc làm',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),

          // Job list
          Expanded(
            child: Consumer<JobProvider>(
              builder: (context, provider, child) {
                if (provider.isLoading && provider.jobs.isEmpty) {
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

  Widget _buildFilterBar(JobProvider jobProvider, ProfileProvider profileProvider) {
    return Container(
      height: 50,
      color: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          // Job Type Filter
          _buildDropdownFilter<int?>(
            label: 'Loại hình',
            isSelected: jobProvider.filter.jobTypeId != null,
            value: jobProvider.filter.jobTypeId,
            options: [
              const PopupMenuItem(value: null, child: Text('Tất cả loại hình')),
              ...profileProvider.jobTypes.map((type) => PopupMenuItem(
                value: type.id,
                child: Text(type.name, style: const TextStyle(fontSize: 14)),
              )),
            ],
            onSelected: (id) {
              jobProvider.updateFilter(jobProvider.filter.copyWith(jobTypeId: id));
            },
          ),
          
          // Province Filter
          _buildDropdownFilter<int?>(
            label: 'Địa điểm',
            isSelected: jobProvider.filter.provinceId != null,
            value: jobProvider.filter.provinceId,
            options: [
              const PopupMenuItem(value: null, child: Text('Toàn quốc')),
              ...profileProvider.provinces.map((province) => PopupMenuItem(
                value: province.id,
                child: Text(province.name, style: const TextStyle(fontSize: 14)),
              )),
            ],
            onSelected: (id) {
              jobProvider.updateFilter(jobProvider.filter.copyWith(provinceId: id));
            },
          ),

          // Category Filter
          _buildDropdownFilter<int?>(
            label: 'Ngành nghề',
            isSelected: jobProvider.filter.categoryId != null,
            value: jobProvider.filter.categoryId,
            options: [
              const PopupMenuItem(value: null, child: Text('Tất cả ngành nghề')),
              ...profileProvider.allJobCategories.map((cat) => PopupMenuItem(
                value: cat.id,
                child: Text(cat.name, style: const TextStyle(fontSize: 14)),
              )),
            ],
            onSelected: (id) {
              jobProvider.updateFilter(jobProvider.filter.copyWith(categoryId: id));
            },
          ),

          // Level Filter
          _buildDropdownFilter<int?>(
            label: 'Cấp bậc',
            isSelected: jobProvider.filter.levelId != null,
            value: jobProvider.filter.levelId,
            options: [
              const PopupMenuItem(value: null, child: Text('Tất cả cấp bậc')),
              ...jobProvider.jobLevels.map((level) => PopupMenuItem(
                value: level.id,
                child: Text(level.name, style: const TextStyle(fontSize: 14)),
              )),
            ],
            onSelected: (id) {
              jobProvider.updateFilter(jobProvider.filter.copyWith(levelId: id));
            },
          ),

          _buildAdvanceFilterButton(),
        ],
      ),
    );
  }

  Widget _buildDropdownFilter<T>({
    required String label,
    required bool isSelected,
    required T value,
    required List<PopupMenuEntry<T>> options,
    required Function(T) onSelected,
  }) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: PopupMenuButton<T>(
        onSelected: onSelected,
        itemBuilder: (context) => options,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? Colors.blue.withOpacity(0.1) : Colors.grey[100],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? Colors.blue.withOpacity(0.5) : Colors.transparent,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: isSelected ? Colors.blue : Colors.black54,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  fontSize: 13,
                ),
              ),
              const SizedBox(width: 4),
              Icon(
                Icons.keyboard_arrow_down,
                size: 16,
                color: isSelected ? Colors.blue : Colors.black54,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAdvanceFilterButton() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(12),
      ),
      child: IconButton(
        icon: const Icon(Icons.tune, size: 20),
        onPressed: _showFilterBottomSheet,
      ),
    );
  }
}
