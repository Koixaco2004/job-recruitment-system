import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../providers/headhunting_provider.dart';
import '../../domain/entities/candidate_detail_entity.dart';
import '../../../../features/profile/presentation/providers/profile_provider.dart';
import '../widgets/send_invitation_dialog.dart';
import '../../../monetization/presentation/providers/monetization_provider.dart';
import '../../../monetization/presentation/pages/pricing_page.dart';

class CandidateDetailPage extends StatefulWidget {
  final int candidateId;
  final int? jobId;

  const CandidateDetailPage({
    super.key,
    required this.candidateId,
    this.jobId,
  });

  @override
  State<CandidateDetailPage> createState() => _CandidateDetailPageState();
}

class _CandidateDetailPageState extends State<CandidateDetailPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<HeadhuntingProvider>();
      provider.fetchCandidateDetail(widget.candidateId);
      if (widget.jobId != null) {
        provider.fetchJobApplicants(widget.jobId!);
      }
      context.read<ProfileProvider>().fetchProvincesIfEmpty();
      context.read<ProfileProvider>().fetchJobTypesIfEmpty();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chi tiết ứng viên'),
        elevation: 0,
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        actions: [
          Consumer<HeadhuntingProvider>(
            builder: (context, provider, child) {
              final candidate = provider.selectedCandidateDetail;
              if (candidate?.cvUrl == null) return const SizedBox();
              return IconButton(
                icon: const Icon(Icons.description_outlined),
                onPressed: () => _openUrl(candidate!.cvUrl!),
                tooltip: 'Xem CV',
              );
            },
          ),
          Consumer2<HeadhuntingProvider, MonetizationProvider>(
            builder: (context, provider, monetizationProvider, _) {
              final isSaved = provider.isSaved(widget.candidateId);
              final isVip = monetizationProvider.currentSubscription?.isVip ?? false;
              
              return IconButton(
                icon: Icon(
                  isSaved ? Icons.favorite : Icons.favorite_border,
                  color: isSaved ? Colors.red : Colors.white70,
                ),
                onPressed: () {
                  if (!isVip) {
                    _showVipRequiredDialog(context, 'Lưu ứng viên');
                    return;
                  }
                  provider.toggleSaveCandidate(widget.candidateId);
                },
                tooltip: isSaved ? 'Bỏ lưu' : 'Lưu ứng viên',
              );
            },
          ),
        ],
      ),
      body: Consumer<HeadhuntingProvider>(
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
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => provider.fetchCandidateDetail(widget.candidateId),
                    child: const Text('Thử lại'),
                  ),
                ],
              ),
            );
          }

          final candidate = provider.selectedCandidateDetail;
          if (candidate == null) {
            return const Center(child: Text('Không tìm thấy thông tin ứng viên'));
          }

          return Column(
            children: [
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    _buildHeader(context, candidate),
                    const SizedBox(height: 16),
                    _buildCandidateOverview(context, candidate),
                    const SizedBox(height: 16),
                    if (candidate.bio != null && candidate.bio!.isNotEmpty) ...[
                      _buildSectionTitle('Giới thiệu bản thân'),
                      _buildCard(
                        Text(
                          candidate.bio!,
                          style: const TextStyle(fontSize: 14, height: 1.5),
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                    _buildProfessionalInfo(context, candidate),
                  ],
                ),
              ),
              _buildBottomActions(context, candidate),
            ],
          );
        },
      ),
    );
  }

  Widget _buildHeader(BuildContext context, CandidateDetailEntity candidate) {
    return _buildCard(
      Row(
        children: [
          CircleAvatar(
            radius: 40,
            backgroundImage: candidate.avatarUrl != null ? NetworkImage(candidate.avatarUrl!) : null,
            child: candidate.avatarUrl == null ? const Icon(Icons.person, size: 40) : null,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  candidate.fullName,
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                if (candidate.position != null)
                  Text(
                    candidate.position!,
                    style: TextStyle(color: Theme.of(context).primaryColor, fontWeight: FontWeight.w500),
                  ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.phone, size: 14, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text(candidate.phone ?? 'Chưa cập nhật', style: const TextStyle(color: Colors.grey, fontSize: 13)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCandidateOverview(BuildContext context, CandidateDetailEntity candidate) {
    final profileProvider = context.read<ProfileProvider>();
    final provinceName = profileProvider.getProvinceName(candidate.provinceId);
    
    String salaryText = 'Thỏa thuận';
    if (candidate.salaryMin != null || candidate.salaryMax != null) {
      if (candidate.salaryMin != null && candidate.salaryMax != null) {
        salaryText = '${candidate.salaryMin!.toInt()}M - ${candidate.salaryMax!.toInt()}M VNĐ';
      } else if (candidate.salaryMin != null) {
        salaryText = 'Từ ${candidate.salaryMin!.toInt()}M VNĐ';
      } else {
        salaryText = 'Đến ${candidate.salaryMax!.toInt()}M VNĐ';
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Thông tin chung'),
        _buildCard(
          Column(
            children: [
              _buildInfoRow(Icons.history, 'Kinh nghiệm', '${candidate.yearWorkingExperience} năm'),
              _buildInfoRow(Icons.location_on_outlined, 'Khu vực', provinceName ?? 'Chưa cập nhật'),
              _buildInfoRow(Icons.type_specimen_outlined, 'Loại hình', candidate.jobType?.name ?? 'Chưa cập nhật'),
              _buildInfoRow(Icons.person_outline, 'Giới tính', candidate.gender == 'male' ? 'Nam' : (candidate.gender == 'female' ? 'Nữ' : 'Khác')),
              _buildInfoRow(Icons.monetization_on_outlined, 'Lương mong muốn', salaryText),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildProfessionalInfo(BuildContext context, CandidateDetailEntity candidate) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (candidate.workExperiences.isNotEmpty) ...[
          _buildSectionTitle('Kinh nghiệm làm việc'),
          ...candidate.workExperiences.map((exp) => _buildCard(
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(child: Text(exp.position, style: const TextStyle(fontWeight: FontWeight.bold))),
                    if (exp.isWorkingHere)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text('Hiện tại', style: TextStyle(color: Colors.green, fontSize: 10, fontWeight: FontWeight.bold)),
                      ),
                  ],
                ),
                Text(exp.companyName, style: TextStyle(color: Colors.grey[600], fontSize: 13)),
                Text(
                  '${exp.startDate != null ? DateFormat('MM/yyyy').format(exp.startDate!) : "Chưa rõ"} - ${exp.isWorkingHere ? "Hiện tại" : (exp.endDate != null ? DateFormat('MM/yyyy').format(exp.endDate!) : "")}',
                  style: TextStyle(color: Colors.grey[500], fontSize: 12),
                ),
                if (exp.description != null && exp.description!.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(exp.description!, style: const TextStyle(fontSize: 13, height: 1.4)),
                ],
              ],
            ),
            margin: const EdgeInsets.only(bottom: 12),
          )),
          const SizedBox(height: 16),
        ],
        if (candidate.educations.isNotEmpty) ...[
          _buildSectionTitle('Học vấn'),
          ...candidate.educations.map((edu) => _buildCard(
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(edu.schoolName, style: const TextStyle(fontWeight: FontWeight.bold)),
                Text('${edu.degree ?? ""} - ${edu.major}', style: TextStyle(color: Colors.grey[600], fontSize: 13)),
                Text(
                  '${edu.startDate != null ? DateFormat('MM/yyyy').format(edu.startDate!) : ""} - ${edu.isStillStudying ? "Hiện tại" : (edu.endDate != null ? DateFormat('MM/yyyy').format(edu.endDate!) : "")}',
                  style: TextStyle(color: Colors.grey[500], fontSize: 12),
                ),
                 if (edu.description != null && edu.description!.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(edu.description!, style: const TextStyle(fontSize: 13, height: 1.4)),
                ],
              ],
            ),
            margin: const EdgeInsets.only(bottom: 12),
          )),
          const SizedBox(height: 16),
        ],
        if (candidate.projects.isNotEmpty) ...[
          _buildSectionTitle('Dự án'),
          ...candidate.projects.map((proj) => _buildCard(
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(proj.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                Text(
                  '${proj.startDate != null ? DateFormat('MM/yyyy').format(proj.startDate!) : ""} - ${proj.endDate != null ? DateFormat('MM/yyyy').format(proj.endDate!) : "Hiện tại"}',
                  style: TextStyle(color: Colors.grey[500], fontSize: 12),
                ),
                if (proj.description != null && proj.description!.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(proj.description!, style: const TextStyle(fontSize: 13, height: 1.4)),
                ],
              ],
            ),
            margin: const EdgeInsets.only(bottom: 12),
          )),
          const SizedBox(height: 16),
        ],
        if (candidate.certificates.isNotEmpty) ...[
          _buildSectionTitle('Chứng chỉ'),
          ...candidate.certificates.map((cert) => _buildCard(
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(cert.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                ),
                if (cert.cerImgUrl != null && cert.cerImgUrl!.isNotEmpty)
                  GestureDetector(
                    onTap: () => _openUrl(cert.cerImgUrl!),
                    child: Container(
                      width: 80,
                      height: 60,
                      margin: const EdgeInsets.only(left: 12),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey[200]!),
                        image: DecorationImage(
                          image: NetworkImage(cert.cerImgUrl!),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            margin: const EdgeInsets.only(bottom: 12),
          )),
          const SizedBox(height: 16),
        ],
        if (candidate.skills.isNotEmpty) ...[
          _buildSectionTitle('Kỹ năng'),
          _buildCard(
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: candidate.skills.map((skill) => Chip(
                label: Text(skill.skillMetadata.canonicalName, style: const TextStyle(fontSize: 12)),
                backgroundColor: Theme.of(context).primaryColor.withOpacity(0.05),
                side: BorderSide(color: Theme.of(context).primaryColor.withOpacity(0.2)),
                padding: EdgeInsets.zero,
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              )).toList(),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ],
    );
  }

  Widget _buildBottomActions(BuildContext context, CandidateDetailEntity candidate) {
    return Consumer2<HeadhuntingProvider, MonetizationProvider>(
      builder: (context, provider, monetizationProvider, child) {
        final bool isAlreadyApplied = widget.jobId != null && provider.isApplied(candidate.id, widget.jobId!);
        final isVip = monetizationProvider.currentSubscription?.isVip ?? false;
        
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                offset: const Offset(0, -4),
                blurRadius: 10,
              ),
            ],
          ),
          child: SafeArea(
            child: SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: isAlreadyApplied 
                    ? null 
                    : () {
                        if (!isVip) {
                          _showVipRequiredDialog(context, 'Gửi thư mời');
                          return;
                        }
                        _showInvitationDialog(context, candidate);
                      },
                icon: Icon(isAlreadyApplied ? Icons.check_circle_outline : Icons.mail_outline),
                label: Text(
                  isAlreadyApplied ? 'Ứng viên đã ứng tuyển' : 'Gửi thư mời',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: isAlreadyApplied ? Colors.grey[400] : Theme.of(context).primaryColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, left: 4),
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 1.2),
      ),
    );
  }

  Widget _buildCard(Widget child, {EdgeInsetsGeometry? margin, Color? color}) {
    return Container(
      width: double.infinity,
      margin: margin,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color ?? Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: child,
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.blueGrey[400]),
          const SizedBox(width: 12),
          Text(label, style: TextStyle(color: Colors.grey[600], fontSize: 13)),
          const Spacer(),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
        ],
      ),
    );
  }

  void _showInvitationDialog(BuildContext context, CandidateDetailEntity candidate) {
    showDialog(
      context: context,
      builder: (context) => SendInvitationDialog(
        candidate: candidate,
        initialJobId: widget.jobId,
      ),
    );
  }

  Future<void> _openUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  void _showVipRequiredDialog(BuildContext context, String feature) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.workspace_premium, color: Colors.amber),
            SizedBox(width: 8),
            Text('Tính năng VIP'),
          ],
        ),
        content: Text('Tính năng "$feature" chỉ dành cho thành viên VIP. Vui lòng nâng cấp để sử dụng toàn bộ các công cụ Headhunting cao cấp.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Để sau', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const PricingPage()),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.amber[700],
              foregroundColor: Colors.white,
            ),
            child: const Text('Nâng cấp ngay'),
          ),
        ],
      ),
    );
  }
}
