import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../../core/widgets/pdf_viewer_page.dart';
import '../../domain/entities/candidate_profile_entity.dart';
import '../providers/profile_provider.dart';
import 'edit_profile_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<ProfileProvider>();
      provider.fetchProfile();
      // Listen for upload errors and show SnackBar
      provider.addListener(_onProviderChanged);
    });
  }

  @override
  void dispose() {
    // Chỉ remove listener nếu widget vẫn mounted
    try {
      context.read<ProfileProvider>().removeListener(_onProviderChanged);
    } catch (_) {}
    super.dispose();
  }

  void _onProviderChanged() {
    if (!mounted) return;
    final provider = context.read<ProfileProvider>();

    // Show upload error as SnackBar (not full page error)
    if (provider.uploadError != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(provider.uploadError!),
          backgroundColor: Colors.red,
        ),
      );
      provider.clearMessages();
    }

    // Show success message
    if (provider.successMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(provider.successMessage!),
          backgroundColor: Colors.green,
        ),
      );
      provider.clearMessages();
    }
  }

  Future<void> _openPdfUrl(String url) async {
    await PdfViewerPage.open(context, url, title: 'Xem CV');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text(
          'Hồ sơ cá nhân',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        actions: [
          Consumer<ProfileProvider>(
            builder: (context, provider, _) {
              if (provider.profile == null) return const SizedBox.shrink();
              return IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const EditProfilePage()),
                  );
                },
              );
            },
          ),
        ],
      ),
      body: Consumer<ProfileProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text(
                    'Đang tải hồ sơ...',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          // CHỈ hiện full-page error khi profile chưa load được (fetch failed)
          if (provider.errorMessage != null && provider.profile == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
                  const SizedBox(height: 16),
                  Text(
                    provider.errorMessage!,
                    style: const TextStyle(color: Colors.red),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () => provider.fetchProfile(),
                    icon: const Icon(Icons.refresh),
                    label: const Text('Thử lại'),
                  ),
                ],
              ),
            );
          }

          final profile = provider.profile;
          if (profile == null) return const SizedBox.shrink();

          return SingleChildScrollView(
            child: Column(
              children: [
                _buildHeader(profile),
                _buildSearchableToggle(profile, provider),
                _buildPersonalInfo(profile),
                _buildSkillsSection(profile),
                _buildExperienceSection(profile),
                _buildEducationSection(profile),
                _buildCertificateSection(profile),
                _buildLanguageSection(profile),
                _buildCVSection(profile, provider),
                const SizedBox(height: 24),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader(CandidateProfileEntity profile) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: Theme.of(context).primaryColor),
      child: Column(
        children: [
          CircleAvatar(
            radius: 45,
            backgroundColor: Colors.white,
            child: profile.avatarUrl != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(45),
                    child: Image.network(
                      profile.avatarUrl!,
                      width: 90,
                      height: 90,
                      fit: BoxFit.cover,
                    ),
                  )
                : Text(
                    profile.fullName.isNotEmpty
                        ? profile.fullName[0].toUpperCase()
                        : '?',
                    style: TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
          ),
          const SizedBox(height: 12),
          Text(
            profile.fullName,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          if (profile.currentJobTitle != null) ...[
            const SizedBox(height: 4),
            Text(
              profile.currentJobTitle!,
              style: const TextStyle(fontSize: 16, color: Colors.white70),
            ),
          ],
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildHeaderChip(
                Icons.work,
                '${profile.yearsOfExperience} năm KN',
              ),
              const SizedBox(width: 12),
              if (profile.cityName != null)
                _buildHeaderChip(Icons.location_on, profile.cityName!),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSearchableToggle(
    CandidateProfileEntity profile,
    ProfileProvider provider,
  ) {
    final isOn = profile.isSearchable;
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(
          color: isOn
              ? Colors.green.withValues(alpha: 0.3)
              : Colors.grey.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          // Toggle row
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 8, 0),
            child: Row(
              children: [
                Icon(
                  isOn ? Icons.visibility : Icons.visibility_off,
                  color: isOn ? Colors.green : Colors.grey,
                  size: 22,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Trạng thái tìm việc',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        isOn
                            ? 'Đang BẬT — Hồ sơ công khai'
                            : 'Đang TẮT — Hồ sơ riêng tư',
                        style: TextStyle(
                          fontSize: 12,
                          color: isOn ? Colors.green : Colors.grey,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                Switch(
                  value: isOn,
                  activeColor: Colors.green,
                  onChanged: provider.isSaving
                      ? null
                      : (_) => provider.toggleSearchable(),
                ),
              ],
            ),
          ),
          // Description
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 14),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isOn
                    ? Colors.green.withValues(alpha: 0.05)
                    : Colors.grey.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                isOn
                    ? '✅ Nhà tuyển dụng có thể tìm thấy bạn qua công cụ tìm kiếm và chủ động mời phỏng vấn.'
                    : '🔒 Hồ sơ ở chế độ riêng tư. Chỉ nhà tuyển dụng mà bạn nộp đơn mới xem được.',
                style: TextStyle(
                  fontSize: 12,
                  color: isOn ? Colors.green[700] : Colors.grey[600],
                  height: 1.4,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderChip(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: Colors.white),
          const SizedBox(width: 4),
          Text(text, style: const TextStyle(color: Colors.white, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(icon, color: Theme.of(context).primaryColor, size: 22),
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
          ),
          const Divider(height: 1),
          Padding(padding: const EdgeInsets.all(16), child: child),
        ],
      ),
    );
  }

  Widget _buildPersonalInfo(CandidateProfileEntity profile) {
    return _buildSection(
      title: 'Thông tin chung',
      icon: Icons.person,
      child: Column(
        children: [
          _infoRow('Email', profile.email),
          _infoRow('Điện thoại', profile.phone ?? 'Chưa cập nhật'),
          _infoRow(
            'Ngày sinh',
            profile.dateOfBirth != null
                ? DateFormat('dd/MM/yyyy').format(profile.dateOfBirth!)
                : 'Chưa cập nhật',
          ),
          _infoRow('Giới tính', profile.gender ?? 'Chưa cập nhật'),
          _infoRow('Địa chỉ', profile.address ?? 'Chưa cập nhật'),
          _infoRow('Trình độ', profile.educationLevel ?? 'Chưa cập nhật'),
          _infoRow(
            'Vị trí mong muốn',
            profile.desiredJobTitle ?? 'Chưa cập nhật',
          ),
          _infoRow(
            'Mức lương mong muốn',
            profile.desiredSalaryMin != null
                ? '${NumberFormat("#,###").format(profile.desiredSalaryMin)} - ${NumberFormat("#,###").format(profile.desiredSalaryMax)} VND'
                : 'Thỏa thuận',
          ),
          _infoRow('Ngành nghề', profile.industry ?? 'Chưa cập nhật'),
          _infoRow('Hình thức', _jobTypeLabel(profile.desiredJobType)),
        ],
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              label,
              style: const TextStyle(color: Colors.grey, fontSize: 14),
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

  Widget _buildSkillsSection(CandidateProfileEntity profile) {
    return _buildSection(
      title: 'Kỹ năng',
      icon: Icons.code,
      child: profile.skills.isEmpty
          ? const Text('Chưa cập nhật', style: TextStyle(color: Colors.grey))
          : Wrap(
              spacing: 8,
              runSpacing: 8,
              children: profile.skills
                  .map(
                    (skill) => Chip(
                      label: Text(skill, style: const TextStyle(fontSize: 13)),
                      backgroundColor: Theme.of(
                        context,
                      ).primaryColor.withValues(alpha: 0.1),
                    ),
                  )
                  .toList(),
            ),
    );
  }

  Widget _buildExperienceSection(CandidateProfileEntity profile) {
    return _buildSection(
      title: 'Kinh nghiệm làm việc',
      icon: Icons.work_outline,
      child: profile.workExperiences.isEmpty
          ? const Text('Chưa cập nhật', style: TextStyle(color: Colors.grey))
          : Column(
              children: profile.workExperiences.map((exp) {
                return Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              exp.position,
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          if (exp.isCurrentJob)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.green.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Text(
                                'Hiện tại',
                                style: TextStyle(
                                  color: Colors.green,
                                  fontSize: 11,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        exp.companyName,
                        style: TextStyle(
                          color: Theme.of(context).primaryColor,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${DateFormat('MM/yyyy').format(exp.startDate)} - ${exp.endDate != null ? DateFormat('MM/yyyy').format(exp.endDate!) : 'Hiện tại'}',
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 13,
                        ),
                      ),
                      if (exp.description != null) ...[
                        const SizedBox(height: 6),
                        Text(
                          exp.description!,
                          style: const TextStyle(fontSize: 13),
                        ),
                      ],
                      if (profile.workExperiences.last != exp)
                        const Divider(height: 24),
                    ],
                  ),
                );
              }).toList(),
            ),
    );
  }

  Widget _buildEducationSection(CandidateProfileEntity profile) {
    return _buildSection(
      title: 'Học vấn',
      icon: Icons.school,
      child: profile.educations.isEmpty
          ? const Text('Chưa cập nhật', style: TextStyle(color: Colors.grey))
          : Column(
              children: profile.educations.map((edu) {
                return Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${edu.degree} - ${edu.fieldOfStudy}',
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        edu.institution,
                        style: TextStyle(
                          color: Theme.of(context).primaryColor,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${DateFormat('MM/yyyy').format(edu.startDate)} - ${edu.endDate != null ? DateFormat('MM/yyyy').format(edu.endDate!) : 'Hiện tại'}',
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 13,
                        ),
                      ),
                      if (edu.description != null) ...[
                        const SizedBox(height: 6),
                        Text(
                          edu.description!,
                          style: const TextStyle(fontSize: 13),
                        ),
                      ],
                      if (profile.educations.last != edu)
                        const Divider(height: 24),
                    ],
                  ),
                );
              }).toList(),
            ),
    );
  }

  Widget _buildCertificateSection(CandidateProfileEntity profile) {
    return _buildSection(
      title: 'Chứng chỉ / Bằng cấp',
      icon: Icons.verified,
      child: profile.certificates.isEmpty
          ? const Text('Chưa cập nhật', style: TextStyle(color: Colors.grey))
          : Column(
              children: profile.certificates.map((cert) {
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        cert.name,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        cert.issuingOrganization,
                        style: TextStyle(
                          color: Theme.of(context).primaryColor,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Ngày cấp: ${DateFormat('MM/yyyy').format(cert.issueDate)}${cert.expirationDate != null ? ' - HSD: ${DateFormat('MM/yyyy').format(cert.expirationDate!)}' : ''}',
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 13,
                        ),
                      ),
                      if (profile.certificates.last != cert)
                        const Divider(height: 20),
                    ],
                  ),
                );
              }).toList(),
            ),
    );
  }

  Widget _buildLanguageSection(CandidateProfileEntity profile) {
    return _buildSection(
      title: 'Ngoại ngữ',
      icon: Icons.language,
      child: profile.languages.isEmpty
          ? const Text('Chưa cập nhật', style: TextStyle(color: Colors.grey))
          : Column(
              children: profile.languages.map((lang) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          lang.name,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: _proficiencyColor(
                            lang.proficiency,
                          ).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          lang.proficiency,
                          style: TextStyle(
                            color: _proficiencyColor(lang.proficiency),
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
    );
  }

  Widget _buildCVSection(
    CandidateProfileEntity profile,
    ProfileProvider provider,
  ) {
    return _buildSection(
      title: 'CV / Hồ sơ đính kèm',
      icon: Icons.description,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (profile.cvFileUrl != null) ...[
            Row(
              children: [
                const Icon(Icons.picture_as_pdf, color: Colors.red),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'CV đã upload',
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                ),
                const Icon(Icons.check_circle, color: Colors.green, size: 20),
              ],
            ),
            const SizedBox(height: 8),
            InkWell(
              onTap: () => _openPdfUrl(profile.cvFileUrl!),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue.withValues(alpha: 0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.link, size: 16, color: Colors.blue),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        profile.cvFileUrl!,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.blue,
                          decoration: TextDecoration.underline,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Icon(Icons.open_in_new, size: 16, color: Colors.blue),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
          ] else
            const Text('Chưa upload CV', style: TextStyle(color: Colors.grey)),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: provider.isUploadingCV
                  ? null
                  : () => provider.pickAndUploadCV(),
              icon: provider.isUploadingCV
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.upload_file),
              label: Text(
                provider.isUploadingCV ? 'Đang upload...' : 'Upload CV (PDF)',
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _jobTypeLabel(String? jobType) {
    switch (jobType) {
      case 'fulltime':
        return 'Full-time';
      case 'parttime':
        return 'Part-time';
      case 'remote':
        return 'Remote';
      case 'freelance':
        return 'Freelance';
      default:
        return 'Chưa cập nhật';
    }
  }

  Color _proficiencyColor(String proficiency) {
    switch (proficiency) {
      case 'Bản ngữ':
        return Colors.green;
      case 'Cao cấp':
        return Colors.blue;
      case 'Trung cấp':
        return Colors.orange;
      case 'Sơ cấp':
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }
}
