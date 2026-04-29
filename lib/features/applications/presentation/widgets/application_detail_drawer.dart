import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../providers/employer_application_provider.dart';
import '../../domain/entities/application_entity.dart';
import '../../domain/entities/application_note_entity.dart';
import '../../../../features/profile/presentation/providers/profile_provider.dart';
import '../../../../features/auth/presentation/providers/auth_provider.dart';
import 'package:intl/intl.dart';
import '../../../monetization/presentation/providers/monetization_provider.dart';
import '../../../monetization/presentation/pages/pricing_page.dart';
import '../../../notifications/presentation/providers/notification_provider.dart';

class ApplicationDetailDrawer extends StatefulWidget {
  const ApplicationDetailDrawer({
    super.key,
  });

  @override
  State<ApplicationDetailDrawer> createState() => _ApplicationDetailDrawerState();
}

class _ApplicationDetailDrawerState extends State<ApplicationDetailDrawer> {
  int? _lastSubscribedId;
  NotificationProvider? _notificationProvider;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _notificationProvider = Provider.of<NotificationProvider>(context, listen: false);
  }

  @override
  void dispose() {
    _cleanupSubscription();
    super.dispose();
  }

  void _cleanupSubscription() {
    if (_lastSubscribedId != null && _notificationProvider != null) {
      _notificationProvider!.unsubscribeApplicationDetail(_lastSubscribedId!);
      _lastSubscribedId = null;
    }
  }

  void _updateSubscription(int applicationId) {
    if (_lastSubscribedId == applicationId) return;
    if (_notificationProvider == null) return;
    
    _cleanupSubscription();
    _notificationProvider!.subscribeApplicationDetail(applicationId);
    _lastSubscribedId = applicationId;
    debugPrint('📡 Subscribed to Application Detail room: application_detail_$applicationId');
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      width: MediaQuery.of(context).size.width * 0.85,
      child: Consumer3<EmployerApplicationProvider, ProfileProvider, AuthProvider>(
        builder: (context, provider, profileProvider, authProvider, child) {
          if (provider.isLoadingDetail) {
            return const Center(child: CircularProgressIndicator());
          }

          final app = provider.selectedApplication;
          if (app == null) {
            if (provider.errorMessage != null) {
              return _buildErrorView(context, provider.errorMessage!);
            }
            return const Center(child: Text('Không tìm thấy dữ liệu hồ sơ'));
          }

          // Handle subscription after build
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) _updateSubscription(app.id);
          });

          // Đảm bảo metadata đã được tải
          WidgetsBinding.instance.addPostFrameCallback((_) {
            profileProvider.fetchProvincesIfEmpty();
            profileProvider.fetchJobTypesIfEmpty();
          });

          return Column(
            children: [
              _buildHeader(context, app),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    _buildAiMatchSection(context, app),
                    const SizedBox(height: 16),
                    _buildCandidateOverview(context, app, profileProvider),
                    const SizedBox(height: 16),
                    if (app.candidate?.bio != null && app.candidate!.bio!.isNotEmpty) ...[
                      _buildSectionTitle('Giới thiệu bản thân'),
                      _buildCard(
                        Text(
                          app.candidate!.bio!,
                          style: const TextStyle(fontSize: 14, height: 1.5),
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                    if (app.coverLetter != null && app.coverLetter!.isNotEmpty) ...[
                      _buildSectionTitle('Thư ngỏ'),
                      _buildCard(Text(app.coverLetter!)),
                      const SizedBox(height: 16),
                    ],
                    _buildProfessionalInfo(context, app),
                    const SizedBox(height: 16),
                    _buildStatusHistory(context, provider),
                    const SizedBox(height: 16),
                    _buildNotesTimeline(context, provider, authProvider),
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
                if (app.profileViewsRemaining != null) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      app.profileViewsRemaining == -1 
                        ? 'Lượt xem: Không giới hạn (VIP)' 
                        : 'Còn ${app.profileViewsRemaining} lượt xem hồ sơ',
                      style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
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

  Widget _buildErrorView(BuildContext context, String message) {
    final isQuotaError = message.contains('30 hồ sơ') || message.contains('giới hạn');
    
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.error_outline, size: 60, color: Colors.red),
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
        ),
        const SizedBox(height: 24),
        if (isQuotaError)
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pop(context);
              Navigator.push(context, MaterialPageRoute(builder: (context) => const PricingPage()));
            },
            icon: const Icon(Icons.workspace_premium),
            label: const Text('Nâng cấp VIP ngay'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.amber[700],
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          )
        else
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Đóng'),
          ),
      ],
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

  Widget _buildCandidateOverview(BuildContext context, ApplicationEntity app, ProfileProvider profileProvider) {
    final candidate = app.candidate;
    
    // Ánh xạ tên từ Metadata
    final provinceName = profileProvider.getProvinceName(candidate?.provinceId);
    final jobTypeName = profileProvider.getJobTypeName(candidate?.jobTypeId);
    
    // Định dạng lương
    String salaryText = 'Thỏa thuận';
    if (candidate?.desiredSalaryMin != null || candidate?.desiredSalaryMax != null) {
      if (candidate?.desiredSalaryMin != null && candidate?.desiredSalaryMax != null) {
        salaryText = '${candidate!.desiredSalaryMin} - ${candidate.desiredSalaryMax} \$';
      } else if (candidate?.desiredSalaryMin != null) {
        salaryText = 'Từ ${candidate!.desiredSalaryMin} \$';
      } else {
        salaryText = 'Đến ${candidate!.desiredSalaryMax} \$';
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Thông tin chung'),
        _buildCard(
          Column(
            children: [
              _buildInfoRow(Icons.ads_click, 'Vị trí mong muốn', candidate?.desiredJobTitle ?? 'Chưa cập nhật'),
              _buildInfoRow(Icons.history, 'Kinh nghiệm', '${candidate?.yearsOfExperience ?? 0} năm'),
              _buildInfoRow(Icons.phone_android, 'Số điện thoại', candidate?.phone ?? 'Chưa cập nhật'),
              _buildInfoRow(Icons.location_on_outlined, 'Khu vực', provinceName ?? candidate?.cityName ?? 'Chưa cập nhật'),
              _buildInfoRow(Icons.type_specimen_outlined, 'Loại hình', jobTypeName ?? 'Chưa cập nhật'),
              _buildInfoRow(Icons.person_outline, 'Giới tính', candidate?.gender ?? 'Chưa cập nhật'),
              _buildInfoRow(Icons.monetization_on_outlined, 'Lương mong muốn', salaryText),
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
        if (candidate.projects.isNotEmpty) ...[
          const SizedBox(height: 16),
          _buildSectionTitle('Dự án'),
          ...candidate.projects.map((proj) => _buildCard(
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(proj.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                if (proj.startDate != null)
                  Text(
                    '${proj.startDate!.year} - ${proj.endDate?.year ?? "Hiện tại"}',
                    style: TextStyle(color: Colors.grey[500], fontSize: 12),
                  ),
                if (proj.description != null && proj.description!.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(proj.description!, style: const TextStyle(fontSize: 13)),
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
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(cert.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                          Text(
                            'Cấp ngày: ${cert.issueDate.day}/${cert.issueDate.month}/${cert.issueDate.year}',
                            style: TextStyle(color: Colors.grey[600], fontSize: 13),
                          ),
                        ],
                      ),
                    ),
                    if (cert.credentialUrl != null && cert.credentialUrl!.isNotEmpty)
                      GestureDetector(
                        onTap: () => _openCv(context, cert.credentialUrl!),
                        child: Container(
                          width: 60,
                          height: 60,
                          margin: const EdgeInsets.only(left: 12),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.grey[200]!),
                            image: DecorationImage(
                              image: NetworkImage(cert.credentialUrl!),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ),
                  ],
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

  Widget _buildNotesTimeline(BuildContext context, EmployerApplicationProvider provider, AuthProvider authProvider) {
    final app = provider.selectedApplication;
    final notes = app?.notes ?? [];
    final currentUserId = authProvider.user?.userId;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildSectionTitle('Ghi chú nội bộ'),
            TextButton.icon(
              onPressed: () => _showNoteDialog(context, provider, applicationId: app?.id),
              icon: const Icon(Icons.add_comment_outlined, size: 16),
              label: const Text('Thêm ghi chú', style: TextStyle(fontSize: 12)),
              style: TextButton.styleFrom(
                visualDensity: VisualDensity.compact,
                foregroundColor: Theme.of(context).primaryColor,
              ),
            ),
          ],
        ),
        if (notes.isEmpty)
          _buildCard(
            const Center(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  'Chưa có ghi chú nào cho ứng viên này',
                  style: TextStyle(color: Colors.grey, fontSize: 13),
                ),
              ),
            ),
          )
        else
          _buildCard(
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Column(
                children: List.generate(notes.length, (index) {
                  final note = notes[index];
                  final isLast = index == notes.length - 1;
                  final isAuthor = note.authorId == currentUserId;

                  return IntrinsicHeight(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Column(
                          children: [
                            Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                image: (note.authorAvatar != null && note.authorAvatar!.isNotEmpty)
                                    ? DecorationImage(
                                        image: NetworkImage(note.authorAvatar!),
                                        fit: BoxFit.cover,
                                      )
                                    : null,
                                color: Colors.blue[100],
                              ),
                              child: (note.authorAvatar == null || note.authorAvatar!.isEmpty)
                                  ? Icon(Icons.person, size: 16, color: Colors.blue[800])
                                  : null,
                            ),
                            if (!isLast)
                              Expanded(
                                child: Container(
                                  width: 2,
                                  color: Colors.grey[200],
                                  margin: const EdgeInsets.symmetric(vertical: 4),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    note.authorName,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    DateFormat('dd/MM HH:mm').format(note.createdAt),
                                    style: TextStyle(
                                      color: Colors.grey[500],
                                      fontSize: 11,
                                    ),
                                  ),
                                  const Spacer(),
                                  if (isAuthor)
                                    IconButton(
                                      icon: const Icon(Icons.edit_outlined, size: 14),
                                      onPressed: () => _showNoteDialog(
                                        context,
                                        provider,
                                        applicationId: app?.id,
                                        note: note,
                                      ),
                                      constraints: const BoxConstraints(),
                                      padding: EdgeInsets.zero,
                                      visualDensity: VisualDensity.compact,
                                      color: Colors.grey[600],
                                    ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: isAuthor ? Colors.blue[50] : Colors.grey[50],
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  note.content,
                                  style: const TextStyle(fontSize: 13, height: 1.4),
                                ),
                              ),
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

  void _showNoteDialog(
    BuildContext context,
    EmployerApplicationProvider provider, {
    int? applicationId,
    ApplicationNoteEntity? note,
  }) {
    final controller = TextEditingController(text: note?.content);
    final isEditing = note != null;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isEditing ? 'Sửa ghi chú' : 'Thêm ghi chú mới'),
        content: TextField(
          controller: controller,
          maxLines: 4,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'Nhập nội dung ghi chú...',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (controller.text.trim().isEmpty) return;

              bool success;
              if (isEditing) {
                success = await provider.updateApplicationNote(
                  applicationId!,
                  note.id,
                  controller.text.trim(),
                );
              } else {
                success = await provider.addApplicationNote(
                  applicationId!,
                  controller.text.trim(),
                );
              }

              if (context.mounted) {
                Navigator.pop(context);
                if (success) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(isEditing ? 'Đã cập nhật ghi chú' : 'Đã thêm ghi chú')),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(provider.errorMessage ?? 'Có lỗi xảy ra')),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).primaryColor,
              foregroundColor: Colors.white,
            ),
            child: Text(isEditing ? 'Cập nhật' : 'Gửi'),
          ),
        ],
      ),
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
                
                // Pipeline Fee Logic UI
                Builder(
                  builder: (context) {
                    final monetizationProvider = context.watch<MonetizationProvider>();
                    final subscription = monetizationProvider.currentSubscription;
                    final creditBalance = monetizationProvider.creditBalance;
                    final isVip = subscription?.isVip ?? false;
                    
                    final isFirstProcessing = (app.status.toLowerCase() == 'applied' && 
                                              selectedStatus != 'applied' && 
                                              selectedStatus != 'rejected' && 
                                              selectedStatus != 'withdrawn');
                    
                    if (!isFirstProcessing) return const SizedBox();

                    int cost = 0;
                    bool hasVipQuota = false;
                    
                    if (isVip && subscription != null) {
                      final remaining = (subscription.package?.monthlyFreeProceeds ?? 0) - subscription.usedFreeProceeds;
                      if (remaining > 0) {
                        cost = 0;
                        hasVipQuota = true;
                      } else {
                        cost = 10;
                      }
                    } else {
                      cost = 10;
                    }

                    final canAfford = cost == 0 || creditBalance >= cost;

                    return Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: canAfford ? Theme.of(context).primaryColor.withOpacity(0.05) : Colors.red.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: canAfford ? Theme.of(context).primaryColor.withOpacity(0.2) : Colors.red.withOpacity(0.2)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.payments_outlined, 
                                size: 18, 
                                color: canAfford ? Theme.of(context).primaryColor : Colors.red
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Phí xử lý hồ sơ',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: canAfford ? Theme.of(context).primaryColor : Colors.red,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          if (hasVipQuota)
                            Text(
                              'Bạn đang sử dụng quyền lợi VIP. Miễn phí xử lý hồ sơ này (${(subscription?.package?.monthlyFreeProceeds ?? 0) - subscription!.usedFreeProceeds} lượt còn lại).',
                              style: const TextStyle(fontSize: 12),
                            )
                          else
                            Text(
                              'Thao tác này sẽ tiêu tốn 10 Credit. Số dư hiện tại: $creditBalance Credit.',
                              style: TextStyle(
                                fontSize: 12,
                                color: canAfford ? Colors.black87 : Colors.red,
                              ),
                            ),
                          if (!canAfford) ...[
                            const SizedBox(height: 8),
                            GestureDetector(
                              onTap: () {
                                Navigator.pop(context);
                                Navigator.push(context, MaterialPageRoute(builder: (context) => const PricingPage()));
                              },
                              child: const Text(
                                'Số dư không đủ. Nạp thêm ngay ->',
                                style: TextStyle(
                                  fontSize: 12, 
                                  color: Colors.red, 
                                  fontWeight: FontWeight.bold,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    );
                  },
                ),
                const SizedBox(height: 16),
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

                      final monetizationProvider = context.read<MonetizationProvider>();
                      final subscription = monetizationProvider.currentSubscription;
                      final creditBalance = monetizationProvider.creditBalance;
                      final isVip = subscription?.isVip ?? false;

                      final isFirstProcessing = (app.status.toLowerCase() == 'applied' && 
                                                selectedStatus != 'applied' && 
                                                selectedStatus != 'rejected' && 
                                                selectedStatus != 'withdrawn');
                      
                      int cost = 0;
                      if (isFirstProcessing) {
                        if (isVip && subscription != null) {
                          final remaining = (subscription.package?.monthlyFreeProceeds ?? 0) - subscription.usedFreeProceeds;
                          cost = remaining > 0 ? 0 : 10;
                        } else {
                          cost = 10;
                        }

                        if (cost > creditBalance) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Số dư Credit không đủ để thực hiện thao tác này.')),
                          );
                          return;
                        }

                        // Confirmation Dialog
                        final confirm = await showDialog<bool>(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Xác nhận xử lý hồ sơ'),
                            content: Text(
                              cost > 0 
                                ? 'Thao tác này sẽ tiêu tốn 10 Credit để đưa ứng viên vào vòng trong. Bạn có chắc chắn muốn tiếp tục?'
                                : 'Thao tác này sẽ sử dụng 1 lượt xử lý miễn phí của gói VIP. Bạn có chắc chắn muốn tiếp tục?'
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context, false),
                                child: const Text('Hủy', style: TextStyle(color: Colors.grey)),
                              ),
                              TextButton(
                                onPressed: () => Navigator.pop(context, true),
                                child: Text('Xác nhận', style: TextStyle(color: Theme.of(context).primaryColor, fontWeight: FontWeight.bold)),
                              ),
                            ],
                          ),
                        );

                        if (confirm != true) return;
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
                          // Refresh balance after successful payment
                          if (isFirstProcessing) {
                            monetizationProvider.fetchCreditBalance();
                            monetizationProvider.fetchSubscriptionStatus();
                          }
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
