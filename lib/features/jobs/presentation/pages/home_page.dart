import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/job_provider.dart';
import '../widgets/job_card.dart';
import 'job_detail_page.dart';
import 'search_page.dart';
import '../../../notifications/presentation/widgets/notification_bell.dart';
import '../../../notifications/presentation/providers/notification_provider.dart';
import '../widgets/filter_bottom_sheet.dart';
import '../../../profile/presentation/providers/profile_provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final jobProvider = context.read<JobProvider>();
      final profileProvider = context.read<ProfileProvider>();

      // Load public jobs
      await jobProvider.fetchPublicJobs(refresh: true);

      // Fetch metadata
      profileProvider.fetchProvincesIfEmpty();
      profileProvider.fetchJobTypesIfEmpty();
      profileProvider.fetchJobCategoriesMetadata();
      jobProvider.fetchJobLevelsIfEmpty();

      // Khởi tạo thông báo
      if (mounted) {
        final notificationProvider = context.read<NotificationProvider>();
        notificationProvider.initSocket();
        notificationProvider.fetchUnreadCount();
        notificationProvider.fetchNotifications(refresh: true);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text(
          'Khám phá ',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 24,
            color: Colors.black87,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        actions: [
          _buildCircleIconButton(
            icon: const NotificationBell(),
            onPressed: () {}, // Handled inside NotificationBell
          ),
          _buildCircleIconButton(
            icon: const Icon(Icons.search, size: 24),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SearchPage()),
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Consumer2<JobProvider, ProfileProvider>(
        builder: (context, jobProvider, profileProvider, child) {
          return Column(
            children: [
              // Search Results Info + Dot
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Tìm thấy ${jobProvider.totalPublicJobs} việc làm',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.sort, color: Colors.blue[600], size: 18),
                        const SizedBox(width: 8),
                        PopupMenuButton<String>(
                          onSelected: (value) {
                            jobProvider.updateFilter(
                              jobProvider.filter.copyWith(
                                sortBy: value,
                              ),
                            );
                          },
                          itemBuilder: (context) => [
                            const PopupMenuItem(
                              value: 'createdAt',
                              child: Text('Mới nhất'),
                            ),
                            const PopupMenuItem(
                              value: 'deadline',
                              child: Text('Hạn nộp'),
                            ),
                            const PopupMenuItem(
                              value: 'salaryMin',
                              child: Text('Mức lương'),
                            ),
                            const PopupMenuItem(
                              value: 'relevance',
                              child: Text('Phù hợp nhất'),
                            ),
                          ],
                          child: Row(
                            children: [
                              Text(
                                _getSortLabel(jobProvider.filter.sortBy),
                                style: TextStyle(color: Colors.blue[700], fontSize: 13, fontWeight: FontWeight.w600),
                              ),
                              Icon(Icons.arrow_drop_down, color: Colors.blue[700], size: 20),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        // Sort Order Dropdown
                        PopupMenuButton<String>(
                          onSelected: (value) {
                            jobProvider.updateFilter(
                              jobProvider.filter.copyWith(
                                sortOrder: value,
                              ),
                            );
                          },
                          itemBuilder: (context) => [
                            const PopupMenuItem(
                              value: 'DESC',
                              child: Row(
                                children: [
                                  Icon(Icons.south, size: 16),
                                  SizedBox(width: 8),
                                  Text('Giảm dần'),
                                ],
                              ),
                            ),
                            const PopupMenuItem(
                              value: 'ASC',
                              child: Row(
                                children: [
                                  Icon(Icons.north, size: 16),
                                  SizedBox(width: 8),
                                  Text('Tăng dần'),
                                ],
                              ),
                            ),
                          ],
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.blue.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  jobProvider.filter.sortOrder == 'DESC' ? Icons.south : Icons.north,
                                  color: Colors.blue[700],
                                  size: 14,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  jobProvider.filter.sortOrder == 'DESC' ? 'Giảm dần' : 'Tăng dần',
                                  style: TextStyle(color: Colors.blue[700], fontSize: 12, fontWeight: FontWeight.w500),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Filter Bar
              _buildFilterBar(jobProvider, profileProvider),

              // Content Area
              Expanded(child: _buildContent(jobProvider)),
            ],
          );
        },
      ),
    );
  }

  Widget _buildContent(JobProvider jobProvider) {
    if (jobProvider.isLoading && jobProvider.jobs.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (jobProvider.errorMessage != null && jobProvider.jobs.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
            const SizedBox(height: 16),
            Text(
              jobProvider.errorMessage!,
              style: const TextStyle(color: Colors.red),
            ),
            ElevatedButton(
              onPressed: () => jobProvider.fetchPublicJobs(refresh: true),
              child: const Text('Thử lại'),
            ),
          ],
        ),
      );
    }

    if (!jobProvider.hasJobs) {
      return ListView(
        children: [
          SizedBox(height: MediaQuery.of(context).size.height * 0.15),
          const Center(
            child: Column(
              children: [
                Icon(Icons.work_off_outlined, size: 80, color: Colors.grey),
                SizedBox(height: 16),
                Text(
                  'Không có việc làm nào',
                  style: TextStyle(color: Colors.grey, fontSize: 16),
                ),
              ],
            ),
          ),
        ],
      );
    }

    return RefreshIndicator(
      onRefresh: () => jobProvider.fetchPublicJobs(refresh: true),
      child: ListView.builder(
        padding: const EdgeInsets.only(top: 8, bottom: 16),
        itemCount: jobProvider.jobs.length + (jobProvider.hasMoreJobs ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == jobProvider.jobs.length) {
            return _buildLoadMoreButton(jobProvider);
          }
          final job = jobProvider.jobs[index];
          return JobCard(
            job: job,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => JobDetailPage(job: job)),
            ),
          );
        },
      ),
    );
  }

  Widget _buildLoadMoreButton(JobProvider provider) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: OutlinedButton(
        onPressed: provider.isLoading
            ? null
            : () => provider.fetchJobs(refresh: false),
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 12),
          side: BorderSide(color: Theme.of(context).primaryColor),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child: provider.isLoading
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : const Text('Xem thêm việc làm'),
      ),
    );
  }

  Widget _buildCircleIconButton({
    required Widget icon,
    required VoidCallback onPressed,
  }) {
    return Container(
      margin: const EdgeInsets.only(right: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: IconButton(
        icon: icon,
        onPressed: onPressed,
        color: Colors.black87,
      ),
    );
  }

  Widget _buildFilterBar(
    JobProvider jobProvider,
    ProfileProvider profileProvider,
  ) {
    return Container(
      height: 50,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          _buildFilterChip(
            label: 'Tất cả',
            isSelected:
                jobProvider.filter.jobTypeId == null &&
                jobProvider.filter.categoryId == null &&
                jobProvider.filter.provinceId == null &&
                jobProvider.filter.levelId == null,
            onTap: () {
              jobProvider.clearFilter();
              jobProvider.fetchPublicJobs(refresh: true);
            },
          ),

          // Job Type Filter
          _buildDropdownFilter<int?>(
            label: 'Loại hình',
            isSelected: jobProvider.filter.jobTypeId != null,
            value: jobProvider.filter.jobTypeId,
            options: [
              const PopupMenuItem(value: null, child: Text('Tất cả loại hình')),
              ...profileProvider.jobTypes.map(
                (type) => PopupMenuItem(
                  value: type.id,
                  child: Text(type.name, style: const TextStyle(fontSize: 14)),
                ),
              ),
            ],
            onSelected: (id) {
              jobProvider.updateFilter(
                jobProvider.filter.copyWith(jobTypeId: id),
              );
              jobProvider.fetchPublicJobs(refresh: true);
            },
          ),

          // Province Filter
          _buildDropdownFilter<int?>(
            label: 'Địa điểm',
            isSelected: jobProvider.filter.provinceId != null,
            value: jobProvider.filter.provinceId,
            options: [
              const PopupMenuItem(value: null, child: Text('Toàn quốc')),
              ...profileProvider.provinces.map(
                (province) => PopupMenuItem(
                  value: province.id,
                  child: Text(
                    province.name,
                    style: const TextStyle(fontSize: 14),
                  ),
                ),
              ),
            ],
            onSelected: (id) {
              jobProvider.updateFilter(
                jobProvider.filter.copyWith(provinceId: id),
              );
              jobProvider.fetchPublicJobs(refresh: true);
            },
          ),

          // Category Filter
          _buildDropdownFilter<int?>(
            label: 'Ngành nghề',
            isSelected: jobProvider.filter.categoryId != null,
            value: jobProvider.filter.categoryId,
            options: [
              const PopupMenuItem(
                value: null,
                child: Text('Tất cả ngành nghề'),
              ),
              ...profileProvider.allJobCategories.map(
                (cat) => PopupMenuItem(
                  value: cat.id,
                  child: Text(cat.name, style: const TextStyle(fontSize: 14)),
                ),
              ),
            ],
            onSelected: (id) {
              jobProvider.updateFilter(
                jobProvider.filter.copyWith(categoryId: id),
              );
              jobProvider.fetchPublicJobs(refresh: true);
            },
          ),

          // Level Filter
          _buildDropdownFilter<int?>(
            label: 'Cấp bậc',
            isSelected: jobProvider.filter.levelId != null,
            value: jobProvider.filter.levelId,
            options: [
              const PopupMenuItem(
                value: null,
                child: Text('Tất cả cấp bậc'),
              ),
              ...jobProvider.jobLevels.map(
                (level) => PopupMenuItem(
                  value: level.id,
                  child: Text(level.name, style: const TextStyle(fontSize: 14)),
                ),
              ),
            ],
            onSelected: (id) {
              jobProvider.updateFilter(
                jobProvider.filter.copyWith(levelId: id),
              );
              jobProvider.fetchPublicJobs(refresh: true);
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
            color: isSelected ? Colors.blue.withOpacity(0.1) : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected
                  ? Colors.blue.withOpacity(0.5)
                  : Colors.grey.withOpacity(0.2),
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

  Widget _buildFilterChip({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? Colors.blue.withOpacity(0.1) : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected
                  ? Colors.blue.withOpacity(0.5)
                  : Colors.grey.withOpacity(0.2),
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.blue : Colors.black54,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              fontSize: 13,
            ),
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
        onPressed: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            builder: (context) => const FilterBottomSheet(),
          );
        },
      ),
    );
  }

  String _getSortLabel(String sortBy) {
    if (sortBy == 'createdAt') return 'Mới nhất';
    if (sortBy == 'deadline') return 'Hạn nộp';
    if (sortBy == 'salaryMin') return 'Mức lương';
    if (sortBy == 'relevance') return 'Phù hợp nhất';
    return 'Cơ bản';
  }
}
