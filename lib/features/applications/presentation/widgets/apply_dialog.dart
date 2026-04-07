import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../jobs/domain/entities/job_post_entity.dart';
import '../providers/application_provider.dart';
import '../../../profile/presentation/providers/profile_provider.dart';

class ApplyDialog extends StatefulWidget {
  final JobPostEntity job;

  const ApplyDialog({super.key, required this.job});

  @override
  State<ApplyDialog> createState() => _ApplyDialogState();
}

class _ApplyDialogState extends State<ApplyDialog> {
  final _coverLetterController = TextEditingController();
  bool _useDefaultCoverLetter = true;

  @override
  void dispose() {
    _coverLetterController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final profileProvider = context.watch<ProfileProvider>();
    final applicationProvider = context.watch<ApplicationProvider>();
    final profile = profileProvider.profile;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Ứng tuyển cho vị trí',
                        style: TextStyle(fontSize: 14, color: Colors.grey),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        widget.job.title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const Divider(height: 24),
            
            const Text(
              'CV của bạn',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue[100]!),
              ),
              child: Row(
                children: [
                  const Icon(Icons.description, color: Colors.blue),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          profile?.fullName ?? 'Chưa cập nhật tên',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          'CV online của bạn',
                          style: TextStyle(fontSize: 12, color: Colors.blue[700]),
                        ),
                      ],
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                      // Navigate to profile to update CV if needed
                      // This is a simple shortcut
                    },
                    child: const Text('Xem CV'),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Thư giới thiệu (Cover Letter)',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                ),
                Transform.scale(
                  scale: 0.8,
                  child: Switch(
                    value: _useDefaultCoverLetter,
                    onChanged: (val) {
                      setState(() {
                        _useDefaultCoverLetter = val;
                      });
                    },
                  ),
                ),
              ],
            ),
            const Text(
              'Thêm một bức thư ngắn gọn để giới thiệu bản thân với nhà tuyển dụng.',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
            const SizedBox(height: 12),
            if (!_useDefaultCoverLetter)
              TextField(
                controller: _coverLetterController,
                maxLines: 4,
                decoration: InputDecoration(
                  hintText: 'VD: Tôi rất ấn tượng với vị trí này...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  contentPadding: const EdgeInsets.all(12),
                ),
              )
            else
              Container(
                padding: const EdgeInsets.all(12),
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'Sử dụng thư giới thiệu mặc định của hệ thống.',
                  style: TextStyle(fontStyle: FontStyle.italic, color: Colors.grey),
                ),
              ),
            
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: applicationProvider.isApplying
                    ? null
                    : () async {
                        final success = await applicationProvider.apply(
                          jobId: widget.job.jobPostId,
                          coverLetter: _useDefaultCoverLetter ? null : _coverLetterController.text,
                          currentCvUrl: profile?.cvFileUrl,
                        );

                        if (mounted) {
                          if (success) {
                            // Làm mới danh sách ứng tuyển để cập nhật trạng thái nút ở trang chi tiết
                            await applicationProvider.fetchMyApplications();
                            
                            if (mounted) {
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Ứng tuyển thành công! Bạn có thể theo dõi đơn ứng tuyển trong mục Nhật ký.'),
                                  backgroundColor: Colors.green,
                                ),
                              );
                            }
                          } else {
                            if (applicationProvider.applyError == 'CV_MISSING') {
                              // Special case for missing CV
                              Navigator.pop(context);
                              _showCvMissingDialog(context);
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(applicationProvider.applyError ?? 'Ứng tuyển thất bại. Vui lòng thử lại.'),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          }
                        }

                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: applicationProvider.isApplying
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Text(
                        'Nộp đơn ngay',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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
        title: const Text('Thiếu CV'),
        content: const Text(
          'Bạn chưa có CV trong hệ thống. Vui lòng cập nhật CV tại trang Hồ sơ cá nhân trước khi ứng tuyển.'
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Để sau'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // In a real app, use a proper navigation route
              // For now, it's handled in the JobDetailPage or similar
              // but I should initiate navigation here if possible.
              // Assuming there's a global key or a way to switch tabs.
            },
            child: const Text('Đến trang hồ sơ'),
          ),
        ],
      ),
    );
  }
}
