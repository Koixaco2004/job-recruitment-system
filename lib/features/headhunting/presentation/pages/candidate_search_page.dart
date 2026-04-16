import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../profile/presentation/providers/profile_provider.dart';
import '../../../profile/domain/entities/job_category_entity.dart';
import '../providers/candidate_search_provider.dart';
import '../widgets/candidate_card.dart';
import '../widgets/candidate_filter_bottom_sheet.dart';
import 'candidate_detail_page.dart';

class CandidateSearchPage extends StatefulWidget {
  const CandidateSearchPage({super.key});

  @override
  State<CandidateSearchPage> createState() => _CandidateSearchPageState();
}

class _CandidateSearchPageState extends State<CandidateSearchPage> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _searchController.text = context.read<CandidateSearchProvider>().filter.keyword;
    _scrollController.addListener(_onScroll);
    
    // Initial fetch
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CandidateSearchProvider>().searchCandidates(refresh: true);
    });
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
      final provider = context.read<CandidateSearchProvider>();
      if (!provider.isLoading && provider.hasMore) {
        provider.searchCandidates(refresh: false);
      }
    }
  }

  void _onSearchChanged(String keyword) {
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      final provider = context.read<CandidateSearchProvider>();
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
      builder: (context) => const CandidateFilterBottomSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text(
          'Tìm kiếm ứng viên',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: theme.primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Search bar
          Container(
            color: theme.primaryColor,
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    onChanged: _onSearchChanged,
                    decoration: InputDecoration(
                      hintText: 'Tìm theo tên, vị trí, kỹ năng...',
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
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Consumer<CandidateSearchProvider>(
                  builder: (context, provider, child) {
                    final filterCount = provider.filter.activeFilterCount;
                    return Stack(
                      children: [
                        IconButton(
                          onPressed: _showFilterBottomSheet,
                          icon: const Icon(Icons.filter_list),
                          style: IconButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: theme.primaryColor,
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
                              constraints: const BoxConstraints(minWidth: 20, minHeight: 20),
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

          // Active filters
          Consumer<CandidateSearchProvider>(
            builder: (context, provider, child) {
              if (!provider.filter.hasActiveFilters) return const SizedBox.shrink();
              return Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                color: Colors.white,
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    ..._buildActiveFilterChips(provider),
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

          // Search results
          Expanded(
            child: Consumer<CandidateSearchProvider>(
              builder: (context, provider, child) {
                if (provider.isLoading && provider.candidates.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (provider.errorMessage != null && provider.candidates.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
                        const SizedBox(height: 16),
                        Text(provider.errorMessage!),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () => provider.searchCandidates(refresh: true),
                          child: const Text('Thử lại'),
                        ),
                      ],
                    ),
                  );
                }

                if (provider.candidates.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.person_search_outlined, size: 80, color: Colors.grey[300]),
                        const SizedBox(height: 16),
                        Text(
                          'Không tìm thấy ứng viên phù hợp',
                          style: theme.textTheme.titleMedium?.copyWith(color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: () => provider.searchCandidates(refresh: true),
                  child: ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.only(top: 8, bottom: 24),
                    itemCount: provider.candidates.length + (provider.hasMore ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index == provider.candidates.length) {
                        return const Center(
                          child: Padding(
                            padding: EdgeInsets.all(16),
                            child: CircularProgressIndicator(),
                          ),
                        );
                      }
                      final candidate = provider.candidates[index];
                      return CandidateCard(
                        candidate: candidate,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => CandidateDetailPage(candidateId: candidate.id),
                            ),
                          );
                        },
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildActiveFilterChips(CandidateSearchProvider provider) {
    final chips = <Widget>[];
    final filter = provider.filter;
    final profileProvider = context.read<ProfileProvider>();

    if (filter.yearsOfExperience != null) {
      chips.add(_buildFilterChip('${filter.yearsOfExperience}+ năm KN', () {
        provider.updateFilter(filter.clearField(experience: true));
      }));
    }

    if (filter.provinceId != null) {
      final name = profileProvider.getProvinceName(filter.provinceId);
      if (name != null) {
        chips.add(_buildFilterChip(name, () {
          provider.updateFilter(filter.clearField(province: true));
        }));
      }
    }

    if (filter.categoryId != null) {
      final category = profileProvider.allJobCategories.firstWhere(
        (c) => c.id == filter.categoryId,
        orElse: () => const JobCategoryEntity(id: -1, name: ''),
      );
      if (category.id != -1) {
        chips.add(_buildFilterChip(category.name, () {
          provider.updateFilter(filter.clearField(category: true));
        }));
      }
    }

    if (filter.jobTypeId != null) {
      final name = profileProvider.getJobTypeName(filter.jobTypeId);
      if (name != null) {
        chips.add(_buildFilterChip(name, () {
          provider.updateFilter(filter.clearField(jobType: true));
        }));
      }
    }

    return chips;
  }

  Widget _buildFilterChip(String label, VoidCallback onDeleted) {
    return Chip(
      label: Text(label, style: const TextStyle(fontSize: 12)),
      onDeleted: onDeleted,
      deleteIcon: const Icon(Icons.close, size: 14),
      backgroundColor: Colors.blue.withOpacity(0.1),
      side: BorderSide.none,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      visualDensity: VisualDensity.compact,
    );
  }
}
