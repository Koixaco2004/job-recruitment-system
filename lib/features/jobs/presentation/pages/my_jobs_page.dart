import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/pages/main_page.dart';
import '../../../profile/presentation/providers/profile_provider.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../providers/job_provider.dart';
import '../providers/my_jobs_provider.dart';
import '../pages/employer_job_edit_page.dart';
import '../widgets/saved_job_card.dart';
import '../../../applications/presentation/widgets/applied_job_card.dart';
import '../../../applications/presentation/providers/application_provider.dart';
import '../widgets/audit_log_modal.dart';

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
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    // Khởi tạo controller với độ dài dựa trên userType nếu có
    final user = context.read<AuthProvider>().user;
    final initialLength = user?.userType == 'employer' ? 3 : 2;
    _tabController = TabController(length: initialLength, vsync: this);
    
    if (user?.userType == 'employer') {
      _tabController.addListener(_handleTabSelection);
      _scrollController.addListener(_onScroll);
    }

    // Fetch data khi load
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = context.read<AuthProvider>();
      final isEmployer = authProvider.user?.userType == 'employer';

      if (isEmployer) {
        // Nếu ban đầu khởi tạo sai độ dài (vì user load chậm), khởi tạo lại
        if (_tabController.length != 3) {
          _tabController.removeListener(_handleTabSelection);
          _tabController.dispose();
          setState(() {
            _tabController = TabController(length: 3, vsync: this);
            _tabController.addListener(_handleTabSelection);
          });
        }
        // Fetch ban đầu cho trang đầu (Tất cả)
        context.read<JobProvider>().fetchEmployerJobs();
      } else {
        // Nếu là Candidate, fetch saved/applied jobs
        final profileProvider = context.read<ProfileProvider>();
        final myJobsProvider = context.read<MyJobsProvider>();
        final candidateId = profileProvider.profile?.candidateId ?? 1;

        myJobsProvider.fetchSavedJobs(candidateId);
        context.read<ApplicationProvider>().fetchMyApplications();

      }
    });
  }

  void _handleTabSelection() {
    if (_tabController.indexIsChanging) return;
    
    final authProvider = context.read<AuthProvider>();
    if (authProvider.user?.userType == 'employer') {
      final status = _getStatusFromIndex(_tabController.index);
      context.read<JobProvider>().fetchEmployerJobs(status: status);
    }
  }

  String? _getStatusFromIndex(int index) {
    if (index == 1) return 'published';
    if (index == 2) return 'draft';
    return null;
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      final provider = context.read<JobProvider>();
      if (!provider.isLoadingEmployerJobs && provider.hasMoreEmployerJobs) {
        final status = _getStatusFromIndex(_tabController.index);
        provider.fetchEmployerJobs(
          page: provider.currentEmployerPage + 1,
          status: status,
        );
      }
    }
  }

  @override
  void dispose() {
    _tabController.removeListener(_handleTabSelection);
    _scrollController.removeListener(_onScroll);
    _tabController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final isEmployer = authProvider.user?.userType == 'employer';

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text(
          isEmployer ? 'Tin tuyển dụng của tôi' : 'Việc của tôi',
          style: const TextStyle(fontWeight: FontWeight.bold),
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
          tabs: isEmployer
              ? const [
                  Tab(text: 'Tất cả'),
                  Tab(text: 'Đang đăng'),
                  Tab(text: 'Bản nháp'),
                ]
              : const [
                  Tab(text: 'Đã lưu'),
                  Tab(text: 'Đã ứng tuyển'),
                ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: isEmployer
          ? [
              _buildEmployerJobsTab(null),
              _buildEmployerJobsTab('published'),
              _buildEmployerJobsTab('draft'),
            ]
          : [_buildSavedJobsTab(), _buildApplicationsTab()],
      ),
      floatingActionButton: isEmployer
          ? FloatingActionButton.extended(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const EmployerJobEditPage(),
                  ),
                );
              },
              backgroundColor: Theme.of(context).primaryColor,
              icon: const Icon(Icons.add, color: Colors.white),
              label: const Text('Đăng tin', style: TextStyle(color: Colors.white)),
            )
          : null,
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

  // === Tab Đã ứng tuyển (Candidate) ===
  Widget _buildApplicationsTab() {
    return Consumer<ApplicationProvider>(
      builder: (context, provider, child) {
        if (provider.isLoadingList) {
          return const Center(child: CircularProgressIndicator());
        }

        if (provider.listError != null) {
          return _buildErrorView(provider.listError!, () {
            provider.fetchMyApplications();
          });
        }

        if (provider.myApplications.isEmpty) {
          return _buildEmptyState(
            icon: Icons.work_outline,
            title: 'Chưa ứng tuyển việc nào',
            subtitle: 'Hãy tìm và ứng tuyển công việc phù hợp với bạn',
          );
        }

        return RefreshIndicator(
          onRefresh: () async {
            await provider.fetchMyApplications();
          },
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: provider.myApplications.length,
            itemBuilder: (context, index) {
              final application = provider.myApplications[index];
              return AppliedJobCard(application: application);
            },
          ),
        );
      },
    );
  }


  // === Tab Nhà tuyển dụng (Employer) ===
  Widget _buildEmployerJobsTab(String? status) {
    return Consumer<JobProvider>(
      builder: (context, provider, child) {
        if (provider.isLoadingEmployerJobs) {
          return const Center(child: CircularProgressIndicator());
        }

        if (provider.errorMessage != null && provider.getEmployerJobsByStatus(status).isEmpty) {
          return _buildErrorView(provider.errorMessage!, () {
            provider.fetchEmployerJobs(status: status);
          });
        }

        final jobs = provider.getEmployerJobsByStatus(status);

        if (jobs.isEmpty) {
          return _buildEmptyState(
            icon: Icons.post_add,
            title: status == 'draft' 
                ? 'Không có bản nháp nào' 
                : (status == 'published' ? 'Chưa có tin nào đang đăng' : 'Bạn chưa đăng tin nào'),
            subtitle: 'Bắt đầu đăng tin để tìm kiếm ứng viên tiềm năng ngay',
            showButton: false,
          );
        }

        return RefreshIndicator(
          onRefresh: () => provider.fetchEmployerJobs(status: status),
          child: ListView.builder(
            controller: _scrollController,
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: jobs.length + (provider.hasMoreEmployerJobs ? 1 : 0),
            itemBuilder: (context, index) {
              if (index == jobs.length) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: CircularProgressIndicator(),
                  ),
                );
              }
              final job = jobs[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => EmployerJobEditPage(
                          jobId: job.jobPostId,
                          job: job,
                        ),
                      ),
                    ).then((value) {
                      if (value == true) {
                        provider.fetchEmployerJobs(status: status);
                      }
                    });
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                job.title,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            _buildStatusBadge(job.status),
                            const SizedBox(width: 8),
                            IconButton(
                              onPressed: () {
                                showModalBottomSheet(
                                  context: context,
                                  isScrollControlled: true,
                                  backgroundColor: Colors.transparent,
                                  builder: (context) => AuditLogModal(
                                    jobId: job.jobPostId,
                                    jobTitle: job.title,
                                  ),
                                );
                              },
                              icon: const Icon(Icons.history, size: 20),
                              tooltip: 'Xem lịch sử duyệt',
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                              color: Colors.grey[600],
                            ),
                          ],
                        ),
                        if (job.status == 'rejected' && job.rejectionReason != null && job.rejectionReason!.isNotEmpty)
                          Container(
                            margin: const EdgeInsets.only(top: 12),
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.red[50],
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.red[100]!),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.error_outline, size: 16, color: Colors.red[700]),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    'Lý do: ${job.rejectionReason}',
                                    style: TextStyle(fontSize: 13, color: Colors.red[700]),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Cập nhật: ${job.updatedAt.day}/${job.updatedAt.month}/${job.updatedAt.year}',
                              style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                            ),
                            if (job.status == 'draft')
                              TextButton.icon(
                                onPressed: () => provider.publishJob(job.jobPostId),
                                icon: const Icon(Icons.publish, size: 18),
                                label: const Text('Đăng ngay'),
                                style: TextButton.styleFrom(
                                  padding: EdgeInsets.zero,
                                  visualDensity: VisualDensity.compact,
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildStatusBadge(String status) {
    Color color;
    String text;
    
    switch (status.toLowerCase()) {
      case 'published':
        color = Colors.green;
        text = 'Đang đăng';
        break;
      case 'draft':
        color = Colors.orange;
        text = 'Bản nháp';
        break;
      case 'approved':
        color = Colors.blue;
        text = 'Đã duyệt';
        break;
      case 'rejected':
        color = Colors.red;
        text = 'Bị từ chối';
        break;
      case 'pending':
        color = Colors.amber;
        text = 'Chờ duyệt';
        break;
      case 'closed':
        color = Colors.grey;
        text = 'Đã đóng';
        break;
      default:
        color = Colors.grey;
        text = status;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  // === Empty State ===
  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String subtitle,
    bool showButton = true,
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
            if (showButton) ...[
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
