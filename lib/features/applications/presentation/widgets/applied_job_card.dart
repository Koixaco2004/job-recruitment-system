import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../domain/entities/application_entity.dart';
import '../pages/application_detail_page.dart';

/// Card hiển thị việc đã ứng tuyển (Sử dụng Application module mới)
class AppliedJobCard extends StatelessWidget {
  final ApplicationEntity application;

  const AppliedJobCard({super.key, required this.application});

  @override
  Widget build(BuildContext context) {
    final statusColor = _getStatusColor(application.status);
    final statusText = _getStatusText(application.status);
    final job = application.job;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey[200]!),
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ApplicationDetailPage(applicationId: application.id),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header: Status badge
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      job?.companyName ?? 'Công ty',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey[600],
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      statusText,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: statusColor,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              
              // Job title
              Text(
                job?.title ?? 'Việc làm',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              
              const SizedBox(height: 12),
              const Divider(),
              const SizedBox(height: 8),
              
              // Footer: Date + Details link
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(Icons.calendar_today, size: 14, color: Colors.grey[500]),
                      const SizedBox(width: 6),
                      Text(
                        'Nộp ngày: ${DateFormat('dd/MM/yyyy').format(application.appliedAt)}',
                        style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      if (application.cvUrlSnapshot != null && application.cvUrlSnapshot!.isNotEmpty)
                        TextButton.icon(
                          onPressed: () => _openCv(context, application.cvUrlSnapshot!),
                          icon: const Icon(Icons.description_outlined, size: 14),
                          label: const Text('Xem CV', style: TextStyle(fontSize: 12)),
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                        ),
                      if (application.cvUrlSnapshot != null && application.cvUrlSnapshot!.isNotEmpty)
                        const SizedBox(width: 8),
                      const Text(
                        'Xem chi tiết',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              
              // AI Score highlight if high
              if (application.matchScore != null && application.matchScore! >= 70) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.green[50],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.auto_awesome, size: 14, color: Colors.green),
                      const SizedBox(width: 6),
                      Text(
                        'Phù hợp: ${application.matchScore!.toInt()}%',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _openCv(BuildContext context, String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Không thể mở CV. Vui lòng thử lại sau.')),
        );
      }
    }
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
      case 'shortlisted': return 'Tiềm năng';
      case 'skill_test': return 'Làm bài test';
      case 'interview': return 'Phỏng vấn';
      case 'offer': return 'Offer';
      case 'hired': return 'Đã trúng tuyển';
      case 'rejected': return 'Bị từ chối';
      case 'withdrawn': return 'Đã rút đơn';
      default: return status;
    }
  }
}
