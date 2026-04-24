import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../domain/entities/job_post_entity.dart';
import '../providers/job_provider.dart';
import '../../../../core/pages/main_page.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../applications/presentation/providers/application_provider.dart';
import '../../../applications/presentation/widgets/apply_dialog.dart';
import '../../../profile/presentation/providers/profile_provider.dart';
import '../../../headhunting/presentation/providers/headhunting_provider.dart';


/// Màn hình chi tiết việc làm
class JobDetailPage extends StatefulWidget {
  final JobPostEntity job;

  const JobDetailPage({super.key, required this.job});

  @override
  State<JobDetailPage> createState() => _JobDetailPageState();
}

class _JobDetailPageState extends State<JobDetailPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<JobProvider>().fetchJobDetail(widget.job.jobPostId);
      
      // Fetch invitations if user is a candidate to sync "Apply" button status
      final authProvider = context.read<AuthProvider>();
      if (authProvider.user?.userType.toLowerCase() == 'candidate') {
        context.read<HeadhuntingProvider>().fetchCandidateInvitations();
      }
    });
  }

  // === Format helpers ===

  String _formatSalary(JobPostEntity job) {
    if (job.salaryType == 'negotiable') return 'Thỏa thuận';
    final fmt = NumberFormat('#,###', 'vi_VN');
    if (job.salaryMin != null && job.salaryMax != null) {
      return '${fmt.format(job.salaryMin)} - ${fmt.format(job.salaryMax)} VND';
    } else if (job.salaryMin != null) {
      return 'Từ ${fmt.format(job.salaryMin)} VND';
    }
    return 'Thỏa thuận';
  }

  String _formatJobType(String type) {
    switch (type) {
      case 'fulltime':
        return 'Full-time';
      case 'parttime':
        return 'Part-time';
      case 'remote':
        return 'Remote';
      case 'freelance':
        return 'Freelance';
      default:
        return type;
    }
  }

  String _formatDegree(String degree) {
    switch (degree) {
      case 'postgraduate':
        return 'Trên đại học';
      case 'university':
        return 'Đại học';
      case 'college':
        return 'Cao đẳng';
      case 'intermediate':
        return 'Trung cấp';
      case 'high_school':
        return 'Trung học';
      case 'certificate':
        return 'Chứng chỉ / Bằng nghề';
      case 'none':
        return 'Không yêu cầu';
      default:
        return degree;
    }
  }


  int _daysRemaining(DateTime deadline) {
    return deadline.difference(DateTime.now()).inDays;
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<JobProvider>(
      builder: (context, provider, child) {
        // Ưu tiên dùng dữ liệu mới nhất từ Provider, nếu đang load hoặc lỗi thì dùng data cũ từ widget
        final job = provider.currentJobDetail ?? widget.job;
        final isLoading = provider.isLoading && provider.currentJobDetail == null;
        final detailError = provider.jobDetailError;

        // Kiểm tra xem tin có bị đóng hoặc hết hạn không
        final isClosed = job.status.toLowerCase() == 'closed' || job.status.toLowerCase() == 'private';
        final isExpired = _daysRemaining(job.deadline) < 0;
        final showExpiredBanner = isClosed || isExpired;

        // Nếu fetch lỗi hoàn toàn và không có cả dữ liệu cũ từ widget (trường hợp hiếm), mới hiện màn hình lỗi
        if (detailError != null && provider.currentJobDetail == null && widget.job.jobPostId == 0) {
          return Scaffold(
            appBar: AppBar(title: const Text('Chi tiết việc làm')),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.info_outline, size: 64, color: Colors.orange[300]),
                  const SizedBox(height: 16),
                  Text(
                    detailError,
                    style: const TextStyle(fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Quay lại'),
                  ),
                ],
              ),
            ),
          );
        }

        return Scaffold(
          backgroundColor: Colors.grey[100],
          body: CustomScrollView(
            slivers: [
              // App bar
              SliverAppBar(
                expandedHeight: 180,
                pinned: true,
                backgroundColor: Theme.of(context).primaryColor,
                foregroundColor: Colors.white,
                flexibleSpace: FlexibleSpaceBar(
                  background: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Theme.of(context).primaryColor,
                          Theme.of(context).primaryColor.withOpacity(0.8),
                        ],
                      ),
                    ),
                    child: SafeArea(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(16, 56, 16, 16),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            // Company logo
                            Container(
                              width: 64,
                              height: 64,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                image: job.companyLogo != null
                                    ? DecorationImage(
                                        image: NetworkImage(job.companyLogo!),
                                        fit: BoxFit.cover,
                                      )
                                    : null,
                              ),
                              child: job.companyLogo == null
                                  ? Icon(
                                      Icons.business,
                                      size: 32,
                                      color: Theme.of(context).primaryColor,
                                    )
                                  : null,
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    job.companyName,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.location_on,
                                        size: 16,
                                        color: Colors.white,
                                      ),
                                      const SizedBox(width: 6),
                                      Expanded(
                                        child: Text(
                                          job.cityName,
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 14,
                                            fontWeight: FontWeight.w500,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.category,
                                        size: 16,
                                        color: Colors.white,
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        job.industryName,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                          letterSpacing: 0.2,
                                        ),
                                      ),
                                    ],
                                  ),
                                  if (isLoading)
                                    const Padding(
                                      padding: EdgeInsets.only(top: 8),
                                      child: SizedBox(
                                        height: 2,
                                        width: 100,
                                        child: LinearProgressIndicator(
                                          backgroundColor: Colors.white24,
                                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white70),
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              // Body
              SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Expired Banner
                    if (showExpiredBanner)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        color: Colors.red[50],
                        child: Row(
                          children: [
                            Icon(Icons.timer_off_outlined, color: Colors.red[700], size: 20),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                isClosed ? 'Tin tuyển dụng này đã được đóng bởi nhà tuyển dụng.' : 'Tin tuyển dụng này đã hết hạn nộp hồ sơ.',
                                style: TextStyle(
                                  color: Colors.red[700],
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    
                    // Job title + badges
                    Container(
                      width: double.infinity,
                      color: Colors.white,
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
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              if (job.isPriority)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 5,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.orange[50],
                                    borderRadius: BorderRadius.circular(6),
                                    border: Border.all(
                                      color: Colors.orange,
                                      width: 1,
                                    ),
                                  ),
                                  child: const Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.local_fire_department,
                                        size: 14,
                                        color: Colors.orange,
                                      ),
                                      SizedBox(width: 4),
                                      Text(
                                        'HOT',
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.orange,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          // Salary highlight
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.green[50],
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.attach_money,
                                  size: 18,
                                  color: Colors.green[700],
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  _formatSalary(job),
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.green[700],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Info grid cards
                    Container(
                      color: Colors.white,
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Thông tin chung',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Wrap(
                            spacing: 12,
                            runSpacing: 12,
                            children: [
                              _buildInfoChip(
                                Icons.work_outline,
                                'Hình thức',
                                _formatJobType(job.jobType),
                                Colors.blue,
                              ),
                              _buildInfoChip(
                                Icons.timer_outlined,
                                'Kinh nghiệm',
                                '${job.experienceRequired} năm',
                                Colors.teal,
                              ),
                              _buildInfoChip(
                                Icons.people_outline,
                                'Số lượng',
                                '${job.numberOfPositions} vị trí',
                                Colors.amber,
                              ),
                              _buildInfoChip(
                                Icons.calendar_today,
                                'Hạn nộp',
                                DateFormat('dd/MM/yyyy').format(job.deadline),
                                _daysRemaining(job.deadline) <= 7 ? Colors.red : Colors.grey,
                              ),
                              if (job.levelName != null)
                                _buildInfoChip(
                                  Icons.bar_chart,
                                  'Cấp bậc',
                                  job.levelName!,
                                  Colors.purple,
                                ),
                              if (job.requiredDegree != null)
                                _buildInfoChip(
                                  Icons.school_outlined,
                                  'Bằng cấp',
                                  _formatDegree(job.requiredDegree!),
                                  Colors.indigo,
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),

                    // === Skills section ===
                    if (job.skills != null && job.skills!.isNotEmpty) ...[
                      Container(
                        width: double.infinity,
                        color: Colors.white,
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Row(
                              children: [
                                Icon(Icons.psychology_outlined, size: 20, color: Colors.deepPurple),
                                SizedBox(width: 8),
                                Text(
                                  'Kỹ năng yêu cầu',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: job.skills!.map((skill) {
                                final skillName = (skill is Map && skill['skillMetadata'] != null)
                                    ? skill['skillMetadata']['canonicalName'] ?? 'Skill'
                                    : 'Skill';
                                return Chip(
                                  label: Text(
                                    skillName,
                                    style: const TextStyle(fontSize: 12, color: Colors.deepPurple),
                                  ),
                                  backgroundColor: Colors.deepPurple[50],
                                  side: BorderSide.none,
                                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 0),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                                );
                              }).toList(),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                    ],

                    // Stats
                    Container(
                      color: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      child: Row(
                        children: [
                          _buildStat(
                            Icons.visibility,
                            '${job.viewCount}',
                            'Lượt xem',
                          ),
                          Container(width: 1, height: 30, color: Colors.grey[300]),
                          _buildStat(
                            Icons.people,
                            '${job.applicationCount}',
                            'Đã ứng tuyển',
                          ),
                          Container(width: 1, height: 30, color: Colors.grey[300]),
                          _buildStat(
                            Icons.schedule,
                            '${_daysRemaining(job.deadline)}',
                            'Ngày còn lại',
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),

                    // === Sections: Mô tả / Yêu cầu / Quyền lợi ===
                    _buildContentSection(
                      icon: Icons.description_outlined,
                      title: 'Mô tả công việc',
                      content: job.description,
                      color: Colors.blue,
                    ),
                    const SizedBox(height: 8),
                    _buildContentSection(
                      icon: Icons.checklist,
                      title: 'Yêu cầu ứng viên',
                      content: job.requirements,
                      color: Colors.orange,
                    ),
                    const SizedBox(height: 8),
                    _buildContentSection(
                      icon: Icons.card_giftcard,
                      title: 'Quyền lợi',
                      content: job.benefits,
                      color: Colors.green,
                    ),

                    // Bottom padding for the sticky button
                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ],
          ),

          // === Sticky bottom bar: Apply button (HIDDEN as requested) ===
          bottomNavigationBar: _buildBottomBar(context, job),
        );
      },
    );
  }

  Widget _buildBottomBar(BuildContext context, JobPostEntity job) {
    final authProvider = context.watch<AuthProvider>();
    final isCandidate = authProvider.user?.userType.toLowerCase() == 'candidate';
    
    // Nếu không phải candidate thì không hiện nút ứng tuyển
    if (!isCandidate) return const SizedBox.shrink();

    final applicationProvider = context.watch<ApplicationProvider>();
    final profileProvider = context.watch<ProfileProvider>();
    
    // Kiểm tra xem tin có bị đóng hoặc hết hạn không
    final isClosed = job.status.toLowerCase() == 'closed' || job.status.toLowerCase() == 'private';
    final isExpired = _daysRemaining(job.deadline) < 0;

    // Kiểm tra đã ứng tuyển chưa
    final isApplied = applicationProvider.myApplications.any(
      (a) => a.jobId == job.jobPostId && a.status != 'withdrawn'
    );

    // Kiểm tra đã chấp nhận lời mời chưa
    final headhuntingProvider = context.watch<HeadhuntingProvider>();
    final isInvitationAccepted = headhuntingProvider.isInvitationAcceptedForJob(job.jobPostId);

    // Vô hiệu hóa nếu: đã ứng tuyển, hoặc đã chấp nhận lời mời, hoặc tin đóng/hết hạn
    final bool isButtonDisabled = isApplied || isInvitationAccepted || isClosed || isExpired;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            // Deadline badge
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 8,
              ),
              decoration: BoxDecoration(
                color: _daysRemaining(job.deadline) <= 7
                    ? Colors.red[50]
                    : Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '${_daysRemaining(job.deadline)}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: _daysRemaining(job.deadline) <= 7
                          ? Colors.red
                          : Colors.grey[700],
                    ),
                  ),
                  Text(
                    'ngày',
                    style: TextStyle(
                      fontSize: 10,
                      color: _daysRemaining(job.deadline) <= 7
                          ? Colors.red
                          : Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            // Apply button
            Expanded(
              child: SizedBox(
                height: 48,
                child: ElevatedButton.icon(
                  onPressed: isButtonDisabled 
                    ? null 
                    : () {
                        // Kiểm tra CV
                        final hasCv = profileProvider.profile?.cvFileUrl != null && 
                                     profileProvider.profile!.cvFileUrl!.isNotEmpty;
                        
                        if (!hasCv) {
                          _showCvMissingDialog(context);
                        } else {
                          showDialog(
                            context: context,
                            builder: (context) => ApplyDialog(job: job),
                          );
                        }
                      },
                  icon: Icon(
                    isApplied || isInvitationAccepted ? Icons.check_circle : (isClosed || isExpired ? Icons.block : Icons.send), 
                    size: 20
                  ),
                  label: Text(
                    isApplied 
                        ? 'Đã ứng tuyển' 
                        : (isInvitationAccepted 
                            ? 'Đã chấp nhận lời mời' 
                            : (isClosed ? 'Công việc đã đóng' : (isExpired ? 'Đã hết hạn nộp' : 'Ứng tuyển ngay'))),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: (isApplied || isInvitationAccepted) ? Colors.grey : Theme.of(context).primaryColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 2,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showCvMissingDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.orange),
            SizedBox(width: 10),
            Text('Thiếu CV'),
          ],
        ),
        content: const Text(
          'Bạn cần cập nhật CV trong hồ sơ cá nhân trước khi ứng tuyển vào công việc này.'
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Để sau', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Close JobDetailPage
              MainPage.switchTab(context, 3); // Switch to Profile Tab
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).primaryColor,
              foregroundColor: Colors.white,
            ),
            child: const Text('Cập nhật ngay'),
          ),
        ],
      ),
    );
  }



  // === Widget helpers ===

  Widget _buildInfoChip(
    IconData icon,
    String label,
    String value,
    Color color,
  ) {
    return Container(
      width: 155,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(0.15), width: 1),
      ),
      child: Row(
        children: [
          Icon(icon, size: 20, color: color),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: color,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStat(IconData icon, String value, String label) {
    return Expanded(
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 16, color: Colors.grey[600]),
              const SizedBox(width: 4),
              Text(
                value,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: 2),
          Text(label, style: TextStyle(fontSize: 11, color: Colors.grey[600])),
        ],
      ),
    );
  }

  Widget _buildContentSection({
    required IconData icon,
    required String title,
    required String content,
    required Color color,
  }) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 20, color: color),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Render từng dòng (hỗ trợ cả \n và dấu -)
          ...content
              .split('\n')
              .map(
                (line) => Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (line.trim().startsWith('-')) ...[
                        Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Container(
                            width: 6,
                            height: 6,
                            decoration: BoxDecoration(
                              color: color.withOpacity(0.6),
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            line.trim().substring(1).trim(),
                            style: const TextStyle(fontSize: 14, height: 1.5),
                          ),
                        ),
                      ] else
                        Expanded(
                          child: Text(
                            line,
                            style: const TextStyle(fontSize: 14, height: 1.5),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
        ],
      ),
    );
  }
}
