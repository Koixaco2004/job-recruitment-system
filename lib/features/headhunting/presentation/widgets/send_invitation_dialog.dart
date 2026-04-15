import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/headhunting_provider.dart';
import '../../domain/entities/candidate_detail_entity.dart';
import '../../../../features/jobs/presentation/providers/job_provider.dart';
import '../../../../features/jobs/domain/entities/job_post_entity.dart';

class SendInvitationDialog extends StatefulWidget {
  final CandidateDetailEntity candidate;
  final int? initialJobId;

  const SendInvitationDialog({
    super.key,
    required this.candidate,
    this.initialJobId,
  });

  @override
  State<SendInvitationDialog> createState() => _SendInvitationDialogState();
}

class _SendInvitationDialogState extends State<SendInvitationDialog> {
  JobPostEntity? _selectedJob;
  final _messageController = TextEditingController();
  bool _isInit = true;

  @override
  void initState() {
    super.initState();
    _messageController.text = 'Chào bạn, chúng tôi thấy hồ sơ của bạn rất phù hợp với vị trí này. Mời bạn tham khảo và ứng tuyển nhé!';
    
    // Clear any previous invitation error when opening the dialog
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<HeadhuntingProvider>().clearError();
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_isInit) {
      context.read<JobProvider>().fetchEmployerJobs(status: 'published');
      _isInit = false;
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Consumer2<HeadhuntingProvider, JobProvider>(
        builder: (context, headhuntingProvider, jobProvider, child) {
          final publishedJobs = jobProvider.publishedJobs;
          
          // Pre-select job if initialJobId is provided and not already selected
          if (_selectedJob == null && widget.initialJobId != null && publishedJobs.isNotEmpty) {
            final matchedJob = publishedJobs.cast<JobPostEntity?>().firstWhere(
              (j) => j?.jobPostId == widget.initialJobId,
              orElse: () => null,
            );
            
            if (matchedJob != null) {
              // We use a microtask or schedule the update to avoid setState during build
              Future.microtask(() {
                if (mounted && _selectedJob == null) {
                  setState(() {
                    _selectedJob = matchedJob;
                  });
                }
              });
            }
          }

          return Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Gửi thư mời ứng tuyển',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  'Mời ứng viên ${widget.candidate.fullName} tham gia tuyển dụng',
                  style: TextStyle(color: Colors.grey[600], fontSize: 13),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Chọn vị trí tuyển dụng *',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 8),
                if (jobProvider.isLoadingEmployerJobs)
                  const Center(child: Padding(padding: EdgeInsets.all(8.0), child: CircularProgressIndicator()))
                else if (publishedJobs.isEmpty)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.orange.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.orange.withValues(alpha: 0.3)),
                    ),
                    child: const Text(
                      'Bạn chưa có tin tuyển dụng nào đang đăng (Published). Vui lòng đăng tin trước khi gửi thư mời.',
                      style: TextStyle(color: Colors.orange, fontSize: 12),
                    ),
                  )
                else
                  DropdownButtonFormField<JobPostEntity>(
                    initialValue: _selectedJob,
                    isExpanded: true,
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    hint: const Text('Chọn công việc', style: TextStyle(fontSize: 14)),
                    items: publishedJobs.map((job) {
                      return DropdownMenuItem<JobPostEntity>(
                        value: job,
                        child: Text(
                          job.title,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 14),
                        ),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedJob = value;
                      });
                    },
                  ),
                const SizedBox(height: 16),
                const Text(
                  'Lời nhắn *',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _messageController,
                  maxLines: 4,
                  decoration: InputDecoration(
                    hintText: 'Nhập lời nhắn cá nhân...',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    contentPadding: const EdgeInsets.all(12),
                  ),
                  style: const TextStyle(fontSize: 14),
                ),
                // Show "Already Invited" message if selected job is in tracked set
                if (_selectedJob != null && headhuntingProvider.isInvited(widget.candidate.id, _selectedJob!.jobPostId)) ...[
                  const SizedBox(height: 8),
                  const Text(
                    'Bạn đã gửi thư mời cho ứng viên này vào vị trí này rồi',
                    style: TextStyle(color: Colors.orange, fontSize: 12, fontWeight: FontWeight.w500),
                  ),
                ] else if (headhuntingProvider.invitationError != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    headhuntingProvider.invitationError!,
                    style: const TextStyle(color: Colors.red, fontSize: 12),
                  ),
                ],
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: headhuntingProvider.isSendingInvitation ? null : () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        child: const Text('Hủy'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: (headhuntingProvider.isSendingInvitation || 
                                    _selectedJob == null || 
                                    _messageController.text.trim().isEmpty ||
                                    headhuntingProvider.isInvited(widget.candidate.id, _selectedJob!.jobPostId))
                            ? null
                            : () => _handleSend(context, headhuntingProvider),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).primaryColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ).copyWith(
                          backgroundColor: WidgetStateProperty.resolveWith((states) {
                            if (states.contains(WidgetState.disabled)) return Colors.grey[300];
                            return Theme.of(context).primaryColor;
                          }),
                        ),
                        child: headhuntingProvider.isSendingInvitation
                            ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                            : const Text('Gửi lời mời'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Future<void> _handleSend(BuildContext context, HeadhuntingProvider provider) async {
    final success = await provider.sendInvitation(
      jobId: _selectedJob!.jobPostId,
      candidateId: widget.candidate.id,
      message: _messageController.text.trim(),
    );

    if (success && mounted) {
      if (context.mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Đã gửi thư mời thành công!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }
}
