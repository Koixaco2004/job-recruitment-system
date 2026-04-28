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
import '../../../applications/presentation/pages/job_kanban_page.dart';
import '../../../headhunting/presentation/pages/suggested_candidates_page.dart';
import '../../../employer/presentation/providers/employer_provider.dart';
import '../../../headhunting/presentation/pages/job_detailed_stats_page.dart';
import '../../../monetization/presentation/providers/monetization_provider.dart';
import '../../../monetization/presentation/pages/pricing_page.dart';
import '../../../monetization/domain/entities/subscription_entity.dart';

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
        // Fetch ban đầu cho trang đầu (Tất cả) và thông tin quota
        context.read<JobProvider>().fetchEmployerJobs();
        context.read<JobProvider>().fetchEmployerJobs(status: 'published');
        context.read<MonetizationProvider>().fetchSubscriptionStatus();
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
      floatingActionButton: (isEmployer && (context.watch<EmployerProvider>().employer?.isAdminCompany ?? false))
          ? FloatingActionButton.extended(
              onPressed: () {
                final monetizationProvider = context.read<MonetizationProvider>();
                final jobProvider = context.read<JobProvider>();
                
                final error = _checkQuota(
                  monetizationProvider.currentSubscription,
                  jobProvider.totalPublishedCount,
                );

                if (error != null) {
                  _showQuotaErrorDialog(context, error);
                } else {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const EmployerJobEditPage(),
                    ),
                  );
                }
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
                  // Sử dụng thông tin job lồng nhau nếu có
                  if (savedJob.job != null) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => JobDetailPage(job: savedJob.job!),
                      ),
                    );
                    return;
                  }

                  // Fallback: Tìm JobPostEntity từ danh sách jobs đã load (Legacy support)
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
    return Consumer2<JobProvider, MonetizationProvider>(
      builder: (context, provider, monetizationProvider, child) {
        if (provider.isLoadingEmployerJobs) {
          return const Center(child: CircularProgressIndicator());
        }

        final jobs = provider.getEmployerJobsByStatus(status);
        final publishedCount = provider.totalPublishedCount;
        final subscription = monetizationProvider.currentSubscription;
        final package = subscription?.package;

        return RefreshIndicator(
          onRefresh: () => provider.fetchEmployerJobs(status: status),
          child: ListView.builder(
            controller: _scrollController,
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(0, 8, 0, 80),
            itemCount: jobs.length + (provider.hasMoreEmployerJobs ? 1 : 0) + 1,
            itemBuilder: (context, index) {
              if (index == 0) {
                // Hiển thị hạn mức (Quota Info)
                return _buildQuotaInfoCard(subscription, publishedCount);
              }
              
              final actualIndex = index - 1;
              if (jobs.isEmpty && actualIndex == 0) {
                return _buildEmptyState(
                  icon: Icons.post_add,
                  title: status == 'draft' 
                      ? 'Không có bản nháp nào' 
                      : (status == 'published' ? 'Chưa có tin nào đang đăng' : 'Bạn chưa đăng tin nào'),
                  subtitle: 'Bắt đầu đăng tin để tìm kiếm ứng viên tiềm năng ngay',
                  showButton: false,
                );
              }

              if (actualIndex >= jobs.length) {
                if (provider.hasMoreEmployerJobs) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: CircularProgressIndicator(),
                    ),
                  );
                }
                return const SizedBox.shrink();
              }

              final job = jobs[actualIndex];
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
                        Text(
                          'Cập nhật: ${job.updatedAt.day}/${job.updatedAt.month}/${job.updatedAt.year}',
                          style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                        ),
                        const SizedBox(height: 8),
                        const Divider(height: 1),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            if (job.applicationCount > 0 || job.status == 'published' || job.status == 'approved')
                              TextButton.icon(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => JobKanbanPage(
                                        jobId: job.jobPostId,
                                        jobTitle: job.title,
                                      ),
                                    ),
                                  );
                                },
                                icon: const Icon(Icons.people_alt_outlined, size: 18),
                                label: const Text('Ứng viên'),
                                style: TextButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(horizontal: 12),
                                  backgroundColor: Colors.blue.withOpacity(0.05),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                ),
                              ),
                            if (job.status == 'published' || job.status == 'approved')
                              TextButton.icon(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => JobDetailedStatsPage(
                                        jobId: job.jobPostId,
                                        jobTitle: job.title,
                                      ),
                                    ),
                                  );
                                },
                                icon: const Icon(Icons.analytics_outlined, size: 18, color: Color(0xFF3B82F6)),
                                label: const Text('Thống kê', style: TextStyle(color: Color(0xFF3B82F6))),
                                style: TextButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(horizontal: 12),
                                  backgroundColor: Colors.blue.withOpacity(0.05),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                ),
                              ),
                            if (job.status == 'published' || job.status == 'approved')
                              TextButton.icon(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => SuggestedCandidatesPage(
                                        jobId: job.jobPostId,
                                      ),
                                    ),
                                  );
                                },
                                icon: const Icon(Icons.auto_awesome_outlined, size: 18, color: Colors.purple),
                                label: const Text('Đề xuất', style: TextStyle(color: Colors.purple)),
                                style: TextButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(horizontal: 12),
                                  backgroundColor: Colors.purple.withOpacity(0.05),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                ),
                              ),
                            if (job.status == 'draft' && (context.read<EmployerProvider>().employer?.isAdminCompany ?? false))
                              TextButton.icon(
                                onPressed: () {
                                  final monetizationProvider = context.read<MonetizationProvider>();
                                  final error = _checkQuota(
                                    monetizationProvider.currentSubscription,
                                    provider.totalPublishedCount,
                                  );

                                  if (error != null) {
                                    _showQuotaErrorDialog(context, error);
                                  } else {
                                    provider.publishJob(job.jobPostId).then((success) {
                                      if (success) {
                                        context.read<MonetizationProvider>().fetchSubscriptionStatus();
                                      }
                                    });
                                  }
                                },
                                icon: const Icon(Icons.publish, size: 18),
                                label: const Text('Đăng ngay'),
                                style: TextButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(horizontal: 12),
                                  backgroundColor: Colors.orange.withOpacity(0.05),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                ),
                              ),
                            if ((job.status == 'published' || job.status == 'approved') && (context.read<EmployerProvider>().employer?.isAdminCompany ?? false))
                              TextButton.icon(
                                onPressed: () => _showCloseConfirmation(context, job.jobPostId, job.title),
                                icon: const Icon(Icons.close, size: 18, color: Colors.red),
                                label: const Text('Đóng tin', style: TextStyle(color: Colors.red)),
                                style: TextButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(horizontal: 12),
                                  backgroundColor: Colors.red.withOpacity(0.05),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
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
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withOpacity(0.5)),
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

  Widget _buildQuotaInfoCard(SubscriptionEntity? subscription, int activeCount) {
    final monetizationProvider = context.watch<MonetizationProvider>();
    
    if (monetizationProvider.isLoadingStatus) {
      return Container(
        margin: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        height: 100,
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
      );
    }

    if (subscription == null) return const SizedBox.shrink();
    
    final package = subscription.package;
    if (package == null) return const SizedBox.shrink();
    
    final maxJobs = package.maxActiveJobs;
    final isFull = activeCount >= maxJobs;
    final isVip = package.isVip;

    // Tính toán cooldown
    DateTime? unlockDate;
    if (!isVip && subscription.lastJobPublishedAt != null) {
      final lastPublish = subscription.lastJobPublishedAt!;
      final cooldownDate = lastPublish.add(Duration(days: package.jobDurationDays));
      if (DateTime.now().isBefore(cooldownDate)) {
        unlockDate = cooldownDate;
      }
    }

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isVip ? Colors.amber[50] : Colors.blue[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: (isVip ? Colors.amber[200] : Colors.blue[200])!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                isVip ? Icons.workspace_premium : Icons.info_outline,
                color: isVip ? Colors.amber[800] : Colors.blue[800],
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Hạn mức tin đăng (${package.displayName})',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: isVip ? Colors.amber[900] : Colors.blue[900],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Tin đang hiển thị:',
                style: TextStyle(color: Colors.grey[700]),
              ),
              Text(
                '$activeCount / $maxJobs',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: isFull ? Colors.red : Colors.black,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: activeCount / maxJobs,
              backgroundColor: Colors.white,
              valueColor: AlwaysStoppedAnimation<Color>(
                isFull ? Colors.red : (isVip ? Colors.amber[700] : Colors.blue[700])!,
              ),
              minHeight: 8,
            ),
          ),
          if (unlockDate != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.red[50],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.timer_outlined, size: 16, color: Colors.red),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Thời gian giãn cách: Bạn có thể đăng tin tiếp theo vào ${unlockDate.day}/${unlockDate.month}/${unlockDate.year} ${unlockDate.hour}:${unlockDate.minute.toString().padLeft(2, '0')}',
                      style: const TextStyle(fontSize: 12, color: Colors.red, fontWeight: FontWeight.w500),
                    ),
                  ),
                ],
              ),
            ),
          ],
          if (!isVip && isFull && unlockDate == null) ...[
            const SizedBox(height: 12),
            Text(
              'Mẹo: Đóng tin cũ để có thể đăng tin mới ngay lập tức.',
              style: TextStyle(fontSize: 12, color: Colors.blue[800], fontStyle: FontStyle.italic),
            ),
          ],
        ],
      ),
    );
  }

  void _showCloseConfirmation(BuildContext context, int jobId, String title) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Xác nhận đóng tin'),
        content: Text('Bạn có chắc chắn muốn đóng tin tuyển dụng "$title"?\n\nSau khi đóng, ứng viên sẽ không thể tìm thấy hoặc ứng tuyển vào tin này nữa.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Hủy', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(dialogContext);
              final success = await context.read<JobProvider>().updateJob(jobId, {'status': 'closed'});
              if (context.mounted) {
                if (success) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Đã đóng tin tuyển dụng'), backgroundColor: Colors.green),
                  );
                  // Refresh quota info
                  context.read<MonetizationProvider>().fetchSubscriptionStatus();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(context.read<JobProvider>().saveJobError ?? 'Có lỗi xảy ra'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
            child: const Text('Đóng tin'),
          ),
        ],
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

  String? _checkQuota(SubscriptionEntity? subscription, int activeCount) {
    if (subscription == null) return null;
    final package = subscription.package;
    if (package == null) return null;

    // 1. Kiểm tra Cooldown Lock (Thứ tự ưu tiên 1)
    if (!package.isVip && subscription.lastJobPublishedAt != null) {
      final lastPublish = subscription.lastJobPublishedAt!;
      final cooldownDate = lastPublish.add(Duration(days: package.jobDurationDays));
      if (DateTime.now().isBefore(cooldownDate)) {
        final diff = cooldownDate.difference(DateTime.now());
        final days = diff.inDays;
        final hours = diff.inHours % 24;
        final mins = diff.inMinutes % 60;
        return 'COOLDOWN:Bạn đang trong thời gian giãn cách. Vui lòng đợi thêm $days ngày $hours giờ $mins phút (Mở khóa vào: ${cooldownDate.day}/${cooldownDate.month}/${cooldownDate.year} ${cooldownDate.hour}:${cooldownDate.minute.toString().padLeft(2, '0')}).';
      }
    }

    // 2. Kiểm tra Concurrency Limit (Thứ tự ưu tiên 2)
    if (activeCount >= package.maxActiveJobs) {
      return 'LIMIT:Bạn đã dùng hết hạn mức tin đăng cho gói ${package.displayName} ($activeCount/${package.maxActiveJobs}). Vui lòng đóng bớt tin cũ hoặc nâng cấp lên gói VIP để tiếp tục.';
    }

    return null;
  }

  void _showQuotaErrorDialog(BuildContext context, String error) {
    final parts = error.split(':');
    final type = parts[0];
    final message = parts[1];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(
              type == 'COOLDOWN' ? Icons.timer_outlined : Icons.block_flipped,
              color: Colors.red,
            ),
            const SizedBox(width: 8),
            Text(type == 'COOLDOWN' ? 'Thời gian giãn cách' : 'Hết hạn mức đăng tin'),
          ],
        ),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('ĐÓNG'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const PricingPage()),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.amber[700], foregroundColor: Colors.white),
            child: const Text('NÂNG CẤP VIP'),
          ),
        ],
      ),
    );
  }
}
