import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../domain/entities/company_entity.dart';
import 'package:provider/provider.dart';
import '../../../profile/presentation/providers/profile_provider.dart';

/// Tab hiển thị thông tin công ty
class CompanyInfoTab extends StatelessWidget {
  final CompanyEntity company;

  const CompanyInfoTab({super.key, required this.company});

  Future<void> _openWebsite(BuildContext context, String url) async {
    final uri = Uri.parse(url);
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Không thể mở website')));
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Lỗi: ${e.toString()}')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final profileProvider = context.read<ProfileProvider>();
    final provinceName = profileProvider.getProvinceName(company.provinceId);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Content/Description
          if (company.content != null || company.description != null) ...[
            const Text(
              'Giới thiệu',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              company.content ?? company.description!,
              style: const TextStyle(fontSize: 14, height: 1.5),
            ),
            const SizedBox(height: 24),
          ],

          // Website
          if (company.website != null) ...[
            _buildInfoRow(
              icon: Icons.language,
              label: 'Website',
              child: InkWell(
                onTap: () => _openWebsite(context, company.website!),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        company.website!,
                        style: const TextStyle(
                          color: Colors.blue,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                    const Icon(Icons.open_in_new, size: 16, color: Colors.blue),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],

          // Email
          if (company.emailContact != null) ...[
            _buildInfoRow(
              icon: Icons.email,
              label: 'Email liên hệ',
              value: company.emailContact!,
            ),
            const SizedBox(height: 16),
          ],

          // Phone
          if (company.phoneContact != null) ...[
            _buildInfoRow(
              icon: Icons.phone,
              label: 'Số điện thoại',
              value: company.phoneContact!,
            ),
            const SizedBox(height: 16),
          ],

          // Company size
          if (company.companySize != null) ...[
            _buildInfoRow(
              icon: Icons.people,
              label: 'Quy mô',
              value: _formatCompanySize(company.companySize!),
            ),
            const SizedBox(height: 16),
          ],

          // Industry
          if (company.industryName != null) ...[
            _buildInfoRow(
              icon: Icons.work,
              label: 'Lĩnh vực',
              value: company.industryName!,
            ),
            const SizedBox(height: 16),
          ],

          // Address
          if (company.address != null || provinceName != null || company.cityName != null) ...[
            _buildInfoRow(
              icon: Icons.location_on,
              label: 'Địa chỉ',
              value: [
                if (company.address != null) company.address,
                if (provinceName != null || company.cityName != null)
                  provinceName ?? company.cityName,
              ].join(', '),
            ),
            const SizedBox(height: 16),
          ],

          // Facebook
          if (company.facebookUrl != null && company.facebookUrl!.isNotEmpty) ...[
            _buildInfoRow(
              icon: Icons.facebook,
              label: 'Facebook',
              child: InkWell(
                onTap: () => _openWebsite(context, company.facebookUrl!),
                child: Text(
                  company.facebookUrl!,
                  style: const TextStyle(color: Colors.blue),
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],

          // LinkedIn
          if (company.linkedinUrl != null && company.linkedinUrl!.isNotEmpty) ...[
            _buildInfoRow(
              icon: Icons.link,
              label: 'LinkedIn',
              child: InkWell(
                onTap: () => _openWebsite(context, company.linkedinUrl!),
                child: Text(
                  company.linkedinUrl!,
                  style: const TextStyle(color: Colors.blue),
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],

          // Benefits
          if (company.benefits != null) ...[
            const SizedBox(height: 8),
            const Text(
              'Phúc lợi',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              company.benefits!,
              style: const TextStyle(fontSize: 14, height: 1.8),
            ),
          ],

          // Images Gallery
          if (company.images != null && company.images!.isNotEmpty) ...[
            const SizedBox(height: 24),
            const Text(
              'Hình ảnh công ty',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 150,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: company.images!.length,
                separatorBuilder: (context, index) => const SizedBox(width: 12),
                itemBuilder: (context, index) {
                  return ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      company.images![index],
                      height: 150,
                      width: 250,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        height: 150,
                        width: 250,
                        color: Colors.grey[200],
                        child: const Icon(Icons.image_not_supported),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    String? value,
    Widget? child,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: Colors.blue[700]),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              child ?? Text(value ?? '', style: const TextStyle(fontSize: 14)),
            ],
          ),
        ),
      ],
    );
  }

  String _formatCompanySize(String size) {
    switch (size) {
      case '1-50':
        return '1-50 nhân viên';
      case '51-200':
        return '51-200 nhân viên';
      case '201-500':
        return '201-500 nhân viên';
      case '501-1000':
        return '501-1000 nhân viên';
      case '1000+':
        return 'Hơn 1000 nhân viên';
      default:
        return size;
    }
  }
}
