import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../providers/employer_application_provider.dart';
import '../../domain/entities/application_entity.dart';

class ApplicationDetailDrawer extends StatelessWidget {
  const ApplicationDetailDrawer({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Drawer(
      width: MediaQuery.of(context).size.width * 0.85,
      child: Consumer<EmployerApplicationProvider>(
        builder: (context, provider, child) {
          if (provider.isLoadingDetail) {
            return const Center(child: CircularProgressIndicator());
          }

          final app = provider.selectedApplication;
          if (app == null) {
            return const Center(child: Text('Không tìm thấy dữ liệu hồ sơ'));
          }

          return Column(
            children: [
              _buildHeader(context, app),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    _buildAiMatchSection(context, app),
                    const SizedBox(height: 16),
                    _buildCandidateOverview(context, app),
                    const SizedBox(height: 16),
                    if (app.coverLetter != null && app.coverLetter!.isNotEmpty) ...[
                      _buildSectionTitle('Thư ngỏ'),
                      _buildCard(Text(app.coverLetter!)),
                      const SizedBox(height: 16),
                    ],
                    _buildProfessionalInfo(context, app),
                    const SizedBox(height: 16),
                    _buildStatusHistory(context, provider),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
              _buildBottomActions(context, app),
            ],
          );
        },
      ),
    );
  }

  Widget _buildHeader(BuildContext context, ApplicationEntity app) {
    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 16,
        bottom: 16,
        left: 16,
        right: 16,
      ),
      color: Theme.of(context).primaryColor,
      child: Row(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundImage: app.candidate?.avatarUrl != null
                ? NetworkImage(app.candidate!.avatarUrl!)
                : null,
            child: app.candidate?.avatarUrl == null
                ? const Icon(Icons.person, size: 30)
                : null,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  app.candidate?.fullName ?? 'Ứng viên #${app.id}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  app.candidate?.email ?? 'Chưa có email',
                  style: const TextStyle(color: Colors.white70, fontSize: 13),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  Widget _buildAiMatchSection(BuildContext context, ApplicationEntity app) {
    final score = app.cvMatchScore ?? 0;
    final color = score >= 70 ? Colors.green : (score >= 40 ? Colors.orange : Colors.red);

    return _buildCard(
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
               const Text(
                'AI Đánh giá sự phù hợp',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: color),
                ),
                child: Text(
                  '${score.toInt()}%',
                  style: TextStyle(color: color, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          if (app.cvMatchReasoning != null) ...[
            const SizedBox(height: 12),
            Text(
              app.cvMatchReasoning!,
              style: TextStyle(color: Colors.grey[800], fontSize: 13, height: 1.4),
            ),
          ],
        ],
      ),
      color: color.withOpacity(0.05),
    );
  }

  Widget _buildCandidateOverview(BuildContext context, ApplicationEntity app) {
    final candidate = app.candidate;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Thông tin chung'),
        _buildCard(
          Column(
            children: [
              _buildInfoRow(Icons.work_outline, 'Vị trí hiện tại', candidate?.currentJobTitle ?? 'Chưa cập nhật'),
              _buildInfoRow(Icons.history, 'Kinh nghiệm', '${candidate?.yearsOfExperience ?? 0} năm'),
              _buildInfoRow(Icons.phone_android, 'Số điện thoại', candidate?.phone ?? 'Chưa cập nhật'),
              _buildInfoRow(Icons.location_on_outlined, 'Khu vực', candidate?.cityName ?? 'Chưa cập nhật'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildProfessionalInfo(BuildContext context, ApplicationEntity app) {
    final candidate = app.candidate;
    if (candidate == null) return const SizedBox();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (candidate.workExperiences.isNotEmpty) ...[
          _buildSectionTitle('Kinh nghiệm làm việc'),
          ...candidate.workExperiences.map((exp) => _buildCard(
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(exp.position, style: const TextStyle(fontWeight: FontWeight.bold)),
                Text(exp.companyName, style: TextStyle(color: Colors.grey[600], fontSize: 13)),
                Text(
                  '${exp.startDate.year} - ${exp.isCurrentJob ? "Hiện tại" : exp.endDate?.year ?? ""}',
                  style: TextStyle(color: Colors.grey[500], fontSize: 12),
                ),
                if (exp.description != null && exp.description!.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(exp.description!, style: const TextStyle(fontSize: 13)),
                ],
              ],
            ),
            margin: const EdgeInsets.only(bottom: 8),
          )),
        ],
        if (candidate.educations.isNotEmpty) ...[
          const SizedBox(height: 16),
          _buildSectionTitle('Học vấn'),
          ...candidate.educations.map((edu) => _buildCard(
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(edu.institution, style: const TextStyle(fontWeight: FontWeight.bold)),
                Text('${edu.degree} - ${edu.fieldOfStudy}', style: TextStyle(color: Colors.grey[600], fontSize: 13)),
                Text('${edu.startDate.year} - ${edu.endDate == null ? "Hiện tại" : edu.endDate?.year ?? ""}',
                    style: TextStyle(color: Colors.grey[500], fontSize: 12)),
              ],
            ),
            margin: const EdgeInsets.only(bottom: 8),
          )),
        ],
        if (candidate.certificates.isNotEmpty) ...[
          const SizedBox(height: 16),
          _buildSectionTitle('Chứng chỉ'),
          ...candidate.certificates.map((cert) => _buildCard(
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(cert.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                Text(
                  'Cấp ngày: ${cert.issueDate.day}/${cert.issueDate.month}/${cert.issueDate.year}',
                  style: TextStyle(color: Colors.grey[600], fontSize: 13),
                ),
              ],
            ),
            margin: const EdgeInsets.only(bottom: 8),
          )),
        ],
        if (candidate.skills.isNotEmpty) ...[
          const SizedBox(height: 16),
          _buildSectionTitle('Kỹ năng'),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: candidate.skills.map((skill) => Chip(
              label: Text(skill, style: const TextStyle(fontSize: 12)),
              backgroundColor: Colors.blue[50],
              side: BorderSide.none,
              padding: EdgeInsets.zero,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            )).toList(),
          ),
        ],
      ],
    );
  }

  Widget _buildStatusHistory(BuildContext context, EmployerApplicationProvider provider) {
    final history = provider.statusHistory;

    if (provider.isLoadingHistory) {
      return const Center(child: Padding(
        padding: EdgeInsets.all(20),
        child: CircularProgressIndicator(),
      ));
    }

    if (provider.errorMessage != null && history.isEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('Lịch sử trạng thái'),
          _buildCard(
            Center(
              child: Text(
                'Lỗi: ${provider.errorMessage}',
                style: const TextStyle(color: Colors.red, fontSize: 13),
              ),
            ),
            color: Colors.red.withOpacity(0.05),
          ),
        ],
      );
    }

    if (history.isEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('Lịch sử trạng thái'),
          _buildCard(
            const Center(
              child: Text(
                'Chưa có lịch sử thay đổi trạng thái',
                style: TextStyle(color: Colors.grey, fontSize: 13),
              ),
            ),
          ),
        ],
      );
    }

    final statusMap = {
      'applied': 'Đã ứng tuyển',
      'shortlisted': 'Tiềm năng',
      'skill_test': 'Kiểm tra kỹ năng',
      'interview': 'Phỏng vấn',
      'offer': 'Đề nghị',
      'hired': 'Đã tuyển',
      'rejected': 'Từ chối',
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Lịch sử trạng thái'),
        _buildCard(
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Column(
              children: List.generate(history.length, (index) {
                final h = history[index];
                final isLast = index == history.length - 1;

                return IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Column(
                        children: [
                          Container(
                            width: 12,
                            height: 12,
                            decoration: BoxDecoration(
                              color: Theme.of(context).primaryColor,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 2),
                              boxShadow: [
                                BoxShadow(
                                  color: Theme.of(context).primaryColor.withOpacity(0.3),
                                  blurRadius: 4,
                                )
                              ],
                            ),
                          ),
                          if (!isLast)
                            Expanded(
                              child: Container(
                                width: 2,
                                color: Colors.grey[300],
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${h.createdAt.day}/${h.createdAt.month}/${h.createdAt.year} ${h.createdAt.hour}:${h.createdAt.minute.toString().padLeft(2, '0')}',
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.grey[600],
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                if (h.oldStatus != null) ...[
                                  _buildStatusBadge(context, h.oldStatus!, statusMap),
                                  const Icon(Icons.arrow_right_alt, size: 14, color: Colors.grey),
                                ],
                                _buildStatusBadge(context, h.newStatus, statusMap),
                              ],
                            ),
                            if (h.reason != null && h.reason!.isNotEmpty) ...[
                              const SizedBox(height: 4),
                              Text(
                                h.reason!,
                                style: TextStyle(fontSize: 12, color: Colors.grey[700], fontStyle: FontStyle.italic),
                              ),
                            ],
                            const SizedBox(height: 16),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatusBadge(BuildContext context, String status, Map<String, String> statusMap) {
    final color = status == 'rejected' ? Colors.red : Colors.blue;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Text(
        statusMap[status] ?? status,
        style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.bold),
      ),
    );
  }

  void _showStatusDialog(BuildContext context, ApplicationEntity app) {
    String selectedStatus = app.status;
    final reasonController = TextEditingController();
    final noteController = TextEditingController();

    final statuses = {
      'applied': 'Đã ứng tuyển',
      'shortlisted': 'Tiềm năng',
      'skill_test': 'Kiểm tra kỹ năng',
      'interview': 'Phỏng vấn',
      'offer': 'Đề nghị',
      'hired': 'Đã tuyển',
      'rejected': 'Từ chối',
    };

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 20,
            right: 20,
            top: 20,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Chuyển trạng thái ứng tuyển',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 8,
                  children: statuses.entries.map((entry) {
                    final isSelected = selectedStatus == entry.key;
                    return ChoiceChip(
                      label: Text(entry.value),
                      selected: isSelected,
                      onSelected: (selected) {
                        if (selected) {
                          setModalState(() => selectedStatus = entry.key);
                        }
                      },
                      selectedColor: Theme.of(context).primaryColor.withOpacity(0.2),
                      labelStyle: TextStyle(
                        color: isSelected ? Theme.of(context).primaryColor : Colors.black87,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),
                if (selectedStatus == 'rejected') ...[
                  TextField(
                    controller: reasonController,
                    decoration: const InputDecoration(
                      labelText: 'Lý do từ chối (Gửi cho ứng viên) *',
                      border: OutlineInputBorder(),
                      hintText: 'VD: Kinh nghiệm chuyên môn chưa phù hợp...',
                    ),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 12),
                ],
                TextField(
                  controller: noteController,
                  decoration: const InputDecoration(
                    labelText: 'Ghi chú nội bộ (Tùy chọn)',
                    border: OutlineInputBorder(),
                    hintText: 'Nhập ghi chú chỉ HR thấy...',
                  ),
                  maxLines: 2,
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: () async {
                      if (selectedStatus == 'rejected' && reasonController.text.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Vui lòng nhập lý do từ chối')),
                        );
                        return;
                      }

                      final provider = context.read<EmployerApplicationProvider>();
                      final success = await provider.updateApplicationStatus(
                        app.id,
                        selectedStatus,
                        reason: reasonController.text.isNotEmpty ? reasonController.text : null,
                        note: noteController.text.isNotEmpty ? noteController.text : null,
                      );

                      if (context.mounted) {
                        Navigator.pop(context);
                        if (success) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Cập nhật trạng thái thành công')),
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Lỗi: ${provider.errorMessage}')),
                          );
                        }
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).primaryColor,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('Xác nhận cập nhật'),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBottomActions(BuildContext context, ApplicationEntity app) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -5)),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: app.cvUrlSnapshot != null && app.cvUrlSnapshot!.isNotEmpty
                  ? () => _openCv(context, app.cvUrlSnapshot!)
                  : null,
              child: const Text('Xem CV Gốc'),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton(
              onPressed: () => _showStatusDialog(context, app),
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).primaryColor,
                foregroundColor: Colors.white,
              ),
              child: const Text('Chuyển trạng thái'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, left: 4),
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.blueGrey,
          letterSpacing: 1.1,
        ),
      ),
    );
  }

  Widget _buildCard(Widget child, {Color? color, EdgeInsets? margin}) {
    return Container(
      width: double.infinity,
      margin: margin,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color ?? Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: child,
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.grey[600]),
          const SizedBox(width: 8),
          Text(label, style: TextStyle(color: Colors.grey[600], fontSize: 13)),
          const Spacer(),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13)),
        ],
      ),
    );
  }

  Future<void> _openCv(BuildContext context, String url) async {
    final uri = Uri.parse(url);
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Không thể mở liên kết CV')),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi khi mở CV: $e')),
        );
      }
    }
  }
}
