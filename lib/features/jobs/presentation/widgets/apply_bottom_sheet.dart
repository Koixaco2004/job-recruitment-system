import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import '../../domain/entities/job_post_entity.dart';
import '../../../profile/presentation/providers/profile_provider.dart';
import '../providers/job_provider.dart';

/// BottomSheet cho form ứng tuyển
class ApplyBottomSheet extends StatefulWidget {
  final JobPostEntity job;

  const ApplyBottomSheet({super.key, required this.job});

  @override
  State<ApplyBottomSheet> createState() => _ApplyBottomSheetState();
}

class _ApplyBottomSheetState extends State<ApplyBottomSheet> {
  final _coverLetterCtrl = TextEditingController();
  String? _cvUrl;
  String? _cvFileName;
  bool _isUploadingCV = false;
  bool _submitted = false;

  @override
  void initState() {
    super.initState();
    // Lấy CV từ profile hiện tại nếu có
    final profile = context.read<ProfileProvider>().profile;
    if (profile?.cvFileUrl != null) {
      _cvUrl = profile!.cvFileUrl;
      _cvFileName = 'CV_${profile.fullName.replaceAll(' ', '_')}.pdf';
    }
  }

  @override
  void dispose() {
    _coverLetterCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickAndUploadCV() async {
    try {
      setState(() => _isUploadingCV = true);

      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
        withData: true,
      );

      if (result == null || result.files.isEmpty) {
        setState(() => _isUploadingCV = false);
        return;
      }

      final file = result.files.first;
      final bytes = file.bytes;

      if (bytes == null) {
        setState(() {
          _isUploadingCV = false;
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Không thể đọc file'),
              backgroundColor: Colors.red,
            ),
          );
        }
        return;
      }

      // Upload qua ProfileRepository (reuse Cloudinary logic)
      final profileRepo = context.read<ProfileProvider>().profileRepository;
      final uploadResult = await profileRepo.uploadCV(bytes, file.name);

      uploadResult.fold(
        (failure) {
          setState(() => _isUploadingCV = false);
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Upload thất bại: ${failure.message}'),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        (url) {
          setState(() {
            _isUploadingCV = false;
            _cvUrl = url;
            _cvFileName = file.name;
          });
        },
      );
    } catch (e) {
      setState(() => _isUploadingCV = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _submitApplication() async {
    final profile = context.read<ProfileProvider>().profile;
    if (profile == null) return;

    final jobProvider = context.read<JobProvider>();

    final success = await jobProvider.submitApplication(
      jobPostId: widget.job.jobPostId,
      candidateId: profile.candidateId,
      cvFileUrl: _cvUrl,
      coverLetter: _coverLetterCtrl.text.isEmpty ? null : _coverLetterCtrl.text,
    );

    if (mounted) {
      if (success) {
        setState(() => _submitted = true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(jobProvider.applyError ?? 'Lỗi gửi đơn'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.85,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: _submitted ? _buildSuccessView() : _buildFormView(),
    );
  }

  Widget _buildSuccessView() {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.green[50],
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.check_circle, size: 64, color: Colors.green[600]),
          ),
          const SizedBox(height: 20),
          const Text(
            'Ứng tuyển thành công!',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'Hồ sơ của bạn đã được gửi đến ${widget.job.companyName}. '
            'Nhà tuyển dụng sẽ liên hệ nếu hồ sơ phù hợp.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
              height: 1.5,
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).primaryColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Đóng',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFormView() {
    final profile = context.watch<ProfileProvider>().profile;
    final jobProvider = context.watch<JobProvider>();

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Handle bar
        Container(
          margin: const EdgeInsets.only(top: 12),
          width: 40,
          height: 4,
          decoration: BoxDecoration(
            color: Colors.grey[300],
            borderRadius: BorderRadius.circular(2),
          ),
        ),

        // Title
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(Icons.send, color: Theme.of(context).primaryColor, size: 22),
              const SizedBox(width: 10),
              const Expanded(
                child: Text(
                  'Ứng tuyển',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
        ),
        const Divider(height: 1),

        // Content
        Flexible(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Job name
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Theme.of(
                      context,
                    ).primaryColor.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: Theme.of(
                        context,
                      ).primaryColor.withValues(alpha: 0.15),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.job.title,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        widget.job.companyName,
                        style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // === Thông tin ứng viên (Read-only) ===
                const Text(
                  'Thông tin ứng viên',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                _buildReadonlyField(
                  Icons.person_outline,
                  'Họ tên',
                  profile?.fullName ?? 'Chưa cập nhật',
                ),
                _buildReadonlyField(
                  Icons.email_outlined,
                  'Email',
                  profile?.email ?? 'Chưa cập nhật',
                ),
                _buildReadonlyField(
                  Icons.phone_outlined,
                  'Số điện thoại',
                  profile?.phone ?? 'Chưa cập nhật',
                ),
                const SizedBox(height: 16),

                // === CV Section ===
                const Text(
                  'CV / Hồ sơ',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                _buildCVSection(),
                const SizedBox(height: 16),

                // === Cover letter ===
                const Text(
                  'Thư giới thiệu (Không bắt buộc)',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _coverLetterCtrl,
                  maxLines: 4,
                  decoration: InputDecoration(
                    hintText:
                        'Viết vài dòng giới thiệu bản thân hoặc lý do ứng tuyển...',
                    hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    contentPadding: const EdgeInsets.all(14),
                  ),
                ),
                const SizedBox(height: 20),

                // === Submit button ===
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton.icon(
                    onPressed: jobProvider.isApplying
                        ? null
                        : _submitApplication,
                    icon: jobProvider.isApplying
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.send, size: 20),
                    label: Text(
                      jobProvider.isApplying ? 'Đang gửi...' : 'Gửi hồ sơ',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).primaryColor,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      disabledBackgroundColor: Theme.of(
                        context,
                      ).primaryColor.withValues(alpha: 0.6),
                      disabledForegroundColor: Colors.white70,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildReadonlyField(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Colors.grey[600]),
          const SizedBox(width: 10),
          SizedBox(
            width: 90,
            child: Text(
              label,
              style: TextStyle(fontSize: 13, color: Colors.grey[600]),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCVSection() {
    if (_isUploadingCV) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.grey[300]!),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            SizedBox(width: 12),
            Text('Đang tải CV lên...'),
          ],
        ),
      );
    }

    if (_cvUrl != null) {
      // Đã có CV
      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.green[50],
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.green[200]!),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.red[50],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.picture_as_pdf,
                color: Colors.red[400],
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _cvFileName ?? 'CV.pdf',
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Đã sẵn sàng',
                    style: TextStyle(fontSize: 12, color: Colors.green[700]),
                  ),
                ],
              ),
            ),
            TextButton(
              onPressed: _pickAndUploadCV,
              child: const Text('Thay đổi'),
            ),
          ],
        ),
      );
    }

    // Chưa có CV
    return InkWell(
      onTap: _pickAndUploadCV,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: Colors.grey[300]!,
            style: BorderStyle.solid,
          ),
        ),
        child: Column(
          children: [
            Icon(
              Icons.cloud_upload_outlined,
              size: 36,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 8),
            Text(
              'Tải CV lên (PDF)',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Nhấn để chọn file từ thiết bị',
              style: TextStyle(fontSize: 12, color: Colors.grey[400]),
            ),
          ],
        ),
      ),
    );
  }
}
