import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../domain/entities/company_entity.dart';

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
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Description
          if (company.description != null) ...[
            const Text(
              'Giới thiệu',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              company.description!,
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
          if (company.address != null || company.cityName != null) ...[
            _buildInfoRow(
              icon: Icons.location_on,
              label: 'Địa chỉ',
              value:
                  '${company.address ?? ''}${company.address != null && company.cityName != null ? ', ' : ''}${company.cityName ?? ''}',
            ),
            const SizedBox(height: 16),
          ],

          // Founded year
          if (company.foundedYear != null) ...[
            _buildInfoRow(
              icon: Icons.calendar_today,
              label: 'Năm thành lập',
              value: company.foundedYear.toString(),
            ),
            const SizedBox(height: 24),
          ],

          // Benefits
          if (company.benefits != null) ...[
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
