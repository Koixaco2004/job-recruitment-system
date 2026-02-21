import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/pages/main_page.dart';
import '../../../profile/presentation/providers/profile_provider.dart';
import '../providers/job_provider.dart';
import '../providers/my_jobs_provider.dart';
import '../widgets/saved_job_card.dart';
import '../widgets/applied_job_card.dart';
import '../pages/job_detail_page.dart';

/// Màn hình "Việc của tôi" với 2 tabs: Đã lưu & Đã ứng tuyển
class MyJobsPage extends StatefulWidget {
  const MyJobsPage({super.key});

  @override
  State<MyJobsPage> createState() => _MyJobsPageState();
}

class _MyJobsPageState extends State<MyJobsPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    // Fetch data khi load
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final profileProvider = context.read<ProfileProvider>();
      final myJobsProvider = context.read<MyJobsProvider>();
      final candidateId = profileProvider.profile?.candidateId ?? 1;

      myJobsProvider.fetchSavedJobs(candidateId);
      myJobsProvider.fetchApplications(candidateId);
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text(
          'Việc của tôi',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          indicatorWeight: 3,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          labelStyle: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
          tabs: const [
            Tab(text: 'Đã lưu'),
            Tab(text: 'Đã ứng tuyển'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [_buildSavedJobsTab(), _buildApplicationsTab()],
      ),
    );
  }

  // === Tab Đã lưu ===
  Widget _buildSavedJobsTab() {
    return Consumer<MyJobsProvider>(
      builder: (context, provider, child) {
        if (provider.isLoadingSaved) {
          return const Center(child: CircularProgressIndicator());
        }

        if (provider.savedJobsError != null) {
          return _buildErrorView(provider.savedJobsError!, () {
            final candidateId =
                context.read<ProfileProvider>().profile?.candidateId ?? 1;
            provider.fetchSavedJobs(candidateId);
          });
        }

        if (!provider.hasSavedJobs) {
          return _buildEmptyState(
            icon: Icons.bookmark_border,
            title: 'Chưa có việc làm nào được lưu',
            subtitle: 'Hãy lưu những công việc bạn quan tâm để xem lại sau',
          );
        }

        return RefreshIndicator(
          onRefresh: () async {
            final candidateId =
                context.read<ProfileProvider>().profile?.candidateId ?? 1;
            await provider.fetchSavedJobs(candidateId);
          },
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: provider.savedJobs.length,
            itemBuilder: (context, index) {
              final savedJob = provider.savedJobs[index];
              return SavedJobCard(
                savedJob: savedJob,
                onUnsave: () async {
                  final success = await provider.unsaveJob(savedJob.savedJobId);
                  if (mounted && success) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Đã bỏ lưu việc làm'),
                        duration: Duration(seconds: 2),
                      ),
                    );
                  }
                },
                onTap: () {
                  // Tìm JobPostEntity từ danh sách jobs đã load
                  final jobProvider = context.read<JobProvider>();
                  try {
                    final job = jobProvider.allJobs.firstWhere(
                      (j) => j.jobPostId == savedJob.jobPostId,
                    );
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => JobDetailPage(job: job),
                      ),
                    );
                  } catch (_) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Không tìm thấy thông tin việc làm'),
                      ),
                    );
                  }
                },
              );
            },
          ),
        );
      },
    );
  }

  // === Tab Đã ứng tuyển ===
  Widget _buildApplicationsTab() {
    return Consumer<MyJobsProvider>(
      builder: (context, provider, child) {
        if (provider.isLoadingApplications) {
          return const Center(child: CircularProgressIndicator());
        }

        if (provider.applicationsError != null) {
          return _buildErrorView(provider.applicationsError!, () {
            final candidateId =
                context.read<ProfileProvider>().profile?.candidateId ?? 1;
            provider.fetchApplications(candidateId);
          });
        }

        if (!provider.hasApplications) {
          return _buildEmptyState(
            icon: Icons.work_outline,
            title: 'Chưa ứng tuyển việc nào',
            subtitle: 'Hãy tìm và ứng tuyển công việc phù hợp với bạn',
          );
        }

        return RefreshIndicator(
          onRefresh: () async {
            final candidateId =
                context.read<ProfileProvider>().profile?.candidateId ?? 1;
            await provider.fetchApplications(candidateId);
          },
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: provider.applications.length,
            itemBuilder: (context, index) {
              final application = provider.applications[index];
              return AppliedJobCard(application: application);
            },
          ),
        );
      },
    );
  }

  // === Empty State ===
  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 64, color: Colors.grey[400]),
            ),
            const SizedBox(height: 24),
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                // Chuyển về tab Khám phá (index 0)
                MainPage.switchTab(context, 0);
              },
              icon: const Icon(Icons.search),
              label: const Text('Khám phá việc làm ngay'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // === Error View ===
  Widget _buildErrorView(String error, VoidCallback onRetry) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
            const SizedBox(height: 16),
            Text(
              error,
              style: const TextStyle(color: Colors.red),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Thử lại'),
            ),
          ],
        ),
      ),
    );
  }
}
