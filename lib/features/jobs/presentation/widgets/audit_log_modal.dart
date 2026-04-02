import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/job_provider.dart';
import '../../domain/entities/job_status_history_entity.dart';
import 'package:intl/intl.dart';

class AuditLogModal extends StatefulWidget {
  final int jobId;
  final String jobTitle;

  const AuditLogModal({
    super.key,
    required this.jobId,
    required this.jobTitle,
  });

  @override
  State<AuditLogModal> createState() => _AuditLogModalState();
}

class _AuditLogModalState extends State<AuditLogModal> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      context.read<JobProvider>().fetchJobHistory(widget.jobId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.7,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Lịch sử duyệt tin',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Text(
              widget.jobTitle,
              style: TextStyle(color: Colors.grey[600], fontSize: 14),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const Divider(),

          // Content
          Expanded(
            child: Consumer<JobProvider>(
              builder: (context, provider, child) {
                if (provider.isLoadingHistory) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (provider.errorMessage != null && provider.jobHistory.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error_outline, size: 48, color: Colors.red),
                        const SizedBox(height: 16),
                        Text(provider.errorMessage!),
                        TextButton(
                          onPressed: () => provider.fetchJobHistory(widget.jobId),
                          child: const Text('Thử lại'),
                        ),
                      ],
                    ),
                  );
                }

                if (provider.jobHistory.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.history, size: 64, color: Colors.grey[300]),
                        const SizedBox(height: 16),
                        const Text(
                          'Chưa có lịch sử thay đổi',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.separated(
                  padding: const EdgeInsets.all(20),
                  itemCount: provider.jobHistory.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 16),
                  itemBuilder: (context, index) {
                    final history = provider.jobHistory[index];
                    return _buildHistoryItem(history);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryItem(JobStatusHistoryEntity history) {
    final dateFormat = DateFormat('dd/MM/yyyy HH:mm');
    final color = _getStatusColor(history.newStatus);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
                boxShadow: [
                  BoxShadow(
                    color: color.withValues(alpha: 0.3),
                    spreadRadius: 2,
                    blurRadius: 4,
                  ),
                ],
              ),
            ),
            Container(
              width: 2,
              height: history.reason != null ? 100 : 40,
              color: Colors.grey[200],
            ),
          ],
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _getStatusText(history.newStatus),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                  Text(
                    dateFormat.format(history.createdAt),
                    style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              if (history.oldStatus.isNotEmpty)
                Text(
                  'Từ: ${_getStatusText(history.oldStatus)}',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              if (history.reason != null && history.reason!.isNotEmpty)
                Container(
                  margin: const EdgeInsets.only(top: 8),
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey[200]!),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Lý do từ Admin:',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: Colors.black54,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        history.reason!,
                        style: const TextStyle(fontSize: 13, color: Colors.black87),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'published':
        return Colors.green;
      case 'approved':
        return Colors.blue;
      case 'rejected':
        return Colors.red;
      case 'pending':
        return Colors.amber;
      case 'closed':
        return Colors.grey;
      case 'draft':
        return Colors.orange;
      default:
        return Colors.blueGrey;
    }
  }

  String _getStatusText(String status) {
    switch (status.toLowerCase()) {
      case 'published':
        return 'Đang đăng';
      case 'approved':
        return 'Đã duyệt';
      case 'rejected':
        return 'Bị từ chối';
      case 'pending':
        return 'Chờ duyệt';
      case 'closed':
        return 'Đã đóng';
      case 'draft':
        return 'Bản nháp';
      default:
        return status;
    }
  }
}
