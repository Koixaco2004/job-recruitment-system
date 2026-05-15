import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../domain/entities/application_entity.dart';
import '../providers/application_provider.dart';
import '../../../jobs/presentation/pages/job_detail_page.dart';

class ApplicationDetailPage extends StatefulWidget {
  final int applicationId;

  const ApplicationDetailPage({super.key, required this.applicationId});

  @override
  State<ApplicationDetailPage> createState() => _ApplicationDetailPageState();
}

class _ApplicationDetailPageState extends State<ApplicationDetailPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ApplicationProvider>().getDetail(widget.applicationId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('Chi tiết đơn ứng tuyển'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
      ),
      body: Consumer<ApplicationProvider>(
        builder: (context, provider, child) {
          if (provider.isLoadingDetail) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.detailError != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    provider.detailError!,
                    style: const TextStyle(color: Colors.red),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => provider.getDetail(widget.applicationId),
                    child: const Text('Thử lại'),
                  ),
                ],
              ),
            );
          }

          final app = provider.currentApplication;
          if (app == null) {
            return const Center(child: Text('Không tìm thấy thông tin đơn ứng tuyển'));
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // === Job Info Card ===
                _buildJobCard(context, app),
                const SizedBox(height: 16),

                // === Status Card ===
                _buildStatusCard(context, app),
                const SizedBox(height: 16),

                // === AI Analysis Card (If available) ===
                if (app.matchScore != null || app.cvMatchScore != null)
                  _buildAIAnalysisCard(context, app),

                const SizedBox(height: 16),

                // === Cover Letter Card ===
                if (app.coverLetter != null && app.coverLetter!.isNotEmpty)
                  _buildCoverLetterCard(app.coverLetter!),

                const SizedBox(height: 16),

                // === Status History Card ===
                if (app.statusHistory != null && app.statusHistory!.isNotEmpty)
                  _buildHistoryCard(app.statusHistory!),

                const SizedBox(height: 32),

                // === CV Snapshot Card ===
                if (app.cvUrlSnapshot != null && app.cvUrlSnapshot!.isNotEmpty)
                  _buildCvSnapshotCard(context, app.cvUrlSnapshot!),

                const SizedBox(height: 16),

                // === Withdraw Button ===
                if (app.status != 'withdrawn' && app.status != 'rejected')
                  _buildWithdrawButton(context, provider),

                const SizedBox(height: 32),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildJobCard(BuildContext context, ApplicationEntity app) {
    final job = app.job;
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: job != null
            ? () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => JobDetailPage(job: job),
                  ),
                )
            : null,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(8),
                      image: job?.companyLogo != null
                          ? DecorationImage(
                              image: NetworkImage(job!.companyLogo!),
                              fit: BoxFit.cover,
                            )
                          : null,
                    ),
                    child: job?.companyLogo == null
                        ? const Icon(Icons.business, color: Colors.grey)
                        : null,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          job?.title ?? 'Việc làm',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          job?.companyName ?? 'Công ty',
                          style: TextStyle(color: Colors.grey[600], fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right, color: Colors.grey),
                ],
              ),
              const Divider(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildJobSmallInfo(Icons.location_on_outlined, job?.cityName ?? 'Địa điểm'),
                  _buildJobSmallInfo(Icons.calendar_today_outlined, 
                    'Nộp: ${DateFormat('dd/MM/yyyy').format(app.appliedAt)}'),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildJobSmallInfo(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 14, color: Colors.grey[600]),
        const SizedBox(width: 4),
        Text(
          text,
          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
        ),
      ],
    );
  }

  Widget _buildStatusCard(BuildContext context, ApplicationEntity app) {
    final statusColor = _getStatusColor(app.status);
    final statusText = _getStatusText(app.status);

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Trạng thái đơn ứng tuyển',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: statusColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: statusColor.withValues(alpha: 0.3)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.info_outline, size: 18, color: statusColor),
                  const SizedBox(width: 8),
                  Text(
                    statusText,
                    style: TextStyle(
                      color: statusColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            if (app.rejectionReason != null && app.rejectionReason!.isNotEmpty) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.red[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red[100]!),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Lý do từ chối:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                        color: Colors.red,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      app.rejectionReason!,
                      style: TextStyle(fontSize: 13, color: Colors.red[700]),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildAIAnalysisCard(BuildContext context, ApplicationEntity app) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.auto_awesome, color: Colors.blue, size: 20),
                SizedBox(width: 8),
                Text(
                  'Phân tích từ AI (Tham khảo)',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 12),
            
            if (app.matchScore != null) ...[
              _buildScoreRow('Độ phù hợp tổng thể', app.matchScore!),
              const SizedBox(height: 8),
              if (app.matchReasoning != null)
                Text(
                  app.matchReasoning!,
                  style: TextStyle(fontSize: 13, color: Colors.grey[700]),
                ),
              const Divider(height: 24),
            ],

            if (app.cvMatchScore != null) ...[
              _buildScoreRow('Phù hợp CV', app.cvMatchScore!),
              const SizedBox(height: 8),
              if (app.cvMatchReasoning != null)
                Text(
                  app.cvMatchReasoning!,
                  style: TextStyle(fontSize: 13, color: Colors.grey[700]),
                ),
            ],

            const SizedBox(height: 8),
            const Text(
              '* Kết quả AI chỉ mang tính chất tham khảo cho nhà tuyển dụng.',
              style: TextStyle(fontSize: 11, color: Colors.grey, fontStyle: FontStyle.italic),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScoreRow(String label, double score) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: _getScoreColor(score).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            '${score.toInt()}%',
            style: TextStyle(
              color: _getScoreColor(score),
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCoverLetterCard(String coverLetter) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Thư giới thiệu',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Text(
              coverLetter,
              style: TextStyle(fontSize: 14, color: Colors.grey[800], height: 1.5),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHistoryCard(List statusHistory) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Lịch sử cập nhật',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            ...statusHistory.map((h) => _buildHistoryItem(h)).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildHistoryItem(dynamic history) {
    // ApplicationStatusHistoryEntity uses newStatus and reason
    final status = history.newStatus;
    final reason = history.reason;
    final date = history.createdAt;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: _getStatusColor(status).withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.circle, size: 10, color: _getStatusColor(status)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _getStatusText(status),
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                    Text(
                      DateFormat('HH:mm dd/MM/yyyy').format(date),
                      style: TextStyle(fontSize: 11, color: Colors.grey[500]),
                    ),
                  ],
                ),
                if (reason != null && reason.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      reason,
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWithdrawButton(BuildContext context, ApplicationProvider provider) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: OutlinedButton.icon(
        onPressed: provider.isWithdrawing 
          ? null 
          : () => _confirmWithdraw(context, provider),
        icon: const Icon(Icons.cancel_outlined, color: Colors.red),
        label: Text(
          provider.isWithdrawing ? 'Đang thực hiện...' : 'Rút đơn ứng tuyển',
          style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
        ),
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: Colors.red),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
    );
  }

  void _confirmWithdraw(BuildContext context, ApplicationProvider provider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Rút đơn ứng tuyển?'),
        content: const Text(
          'Bạn có chắc chắn muốn rút đơn ứng tuyển này? Hành động này không thể hoàn tác.'
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy', style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              final success = await provider.withdraw(widget.applicationId);
              if (mounted && success) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Đã rút đơn ứng tuyển thành công'),
                    backgroundColor: Colors.green,
                  ),
                );
              } else if (mounted && !success) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(provider.withdrawError ?? 'Rút đơn thất bại'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            child: const Text('Đồng ý rút đơn', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'applied': return Colors.blue;
      case 'shortlisted': return Colors.orange;
      case 'skill_test': return Colors.purple;
      case 'interview': return Colors.indigo;
      case 'offer': return Colors.teal;
      case 'hired': return Colors.green;
      case 'rejected': return Colors.red;
      case 'withdrawn': return Colors.grey;
      default: return Colors.grey;
    }
  }

  String _getStatusText(String status) {
    switch (status.toLowerCase()) {
      case 'applied': return 'Đã nộp đơn';
      case 'shortlisted': return 'Trong danh sách tiềm năng';
      case 'skill_test': return 'Làm bài test kỹ năng';
      case 'interview': return 'Mời phỏng vấn';
      case 'offer': return 'Gửi Offer';
      case 'hired': return 'Đã được tuyển';
      case 'rejected': return 'Từ chối';
      case 'withdrawn': return 'Đã rút đơn';
      default: return status;
    }
  }

  Widget _buildCvSnapshotCard(BuildContext context, String url) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Hồ sơ đã nộp',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _openCv(context, url),
                icon: const Icon(Icons.description_outlined),
                label: const Text('Xem lại CV đã nộp'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue[700],
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              '* Đây là bản CV bạn đã sử dụng tại thời điểm ứng tuyển.',
              style: TextStyle(fontSize: 11, color: Colors.grey, fontStyle: FontStyle.italic),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _openCv(BuildContext context, String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Không thể mở CV. Vui lòng thử lại sau.')),
        );
      }
    }
  }

  Color _getScoreColor(double score) {
    if (score >= 80) return Colors.green;
    if (score >= 50) return Colors.orange;
    return Colors.red;
  }
}
