import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/saved_job_entity.dart';

/// Card hiển thị việc đã lưu
class SavedJobCard extends StatelessWidget {
  final SavedJobEntity savedJob;
  final VoidCallback onUnsave;
  final VoidCallback? onTap;

  const SavedJobCard({
    super.key,
    required this.savedJob,
    required this.onUnsave,
    this.onTap,
  });

  String _formatSalary() {
    if (savedJob.salaryType == 'negotiable') return 'Thỏa thuận';
    final fmt = NumberFormat('#,###', 'vi_VN');
    if (savedJob.salaryMin != null && savedJob.salaryMax != null) {
      return '${fmt.format(savedJob.salaryMin! ~/ 1000000)}-${fmt.format(savedJob.salaryMax! ~/ 1000000)} triệu';
    } else if (savedJob.salaryMin != null) {
      return 'Từ ${fmt.format(savedJob.salaryMin! ~/ 1000000)} triệu';
    }
    return 'Thỏa thuận';
  }

  String _formatJobType() {
    switch (savedJob.jobType) {
      case 'fulltime':
        return 'Full-time';
      case 'parttime':
        return 'Part-time';
      case 'remote':
        return 'Remote';
      case 'freelance':
        return 'Freelance';
      default:
        return savedJob.jobType ?? '';
    }
  }

  String _formatJobLevel() {
    switch (savedJob.jobLevel) {
      case 'intern':
        return 'Thực tập';
      case 'fresher':
        return 'Fresher';
      case 'junior':
        return 'Junior';
      case 'middle':
        return 'Middle';
      case 'senior':
        return 'Senior';
      case 'leader':
        return 'Leader';
      case 'manager':
        return 'Manager';
      default:
        return savedJob.jobLevel ?? '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header: Company logo + name + heart button
              Row(
                children: [
                  // Company logo
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: Colors.grey[200],
                      image: savedJob.companyLogo != null
                          ? DecorationImage(
                              image: NetworkImage(savedJob.companyLogo!),
                              fit: BoxFit.cover,
                            )
                          : null,
                    ),
                    child: savedJob.companyLogo == null
                        ? const Icon(Icons.business, color: Colors.grey)
                        : null,
                  ),
                  const SizedBox(width: 12),
                  // Company name
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          savedJob.companyName ?? 'Công ty',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(
                              Icons.location_on,
                              size: 14,
                              color: Colors.grey[600],
                            ),
                            const SizedBox(width: 4),
                            Text(
                              savedJob.cityName ?? '',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  // Heart button (always filled)
                  IconButton(
                    icon: const Icon(Icons.favorite, color: Colors.red),
                    onPressed: onUnsave,
                    tooltip: 'Bỏ lưu',
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Job title
              Text(
                savedJob.jobTitle ?? 'Việc làm',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 12),
              // Job details
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _buildChip(Icons.attach_money, _formatSalary(), Colors.green),
                  if (savedJob.jobType != null)
                    _buildChip(
                      Icons.work_outline,
                      _formatJobType(),
                      Colors.blue,
                    ),
                  if (savedJob.jobLevel != null)
                    _buildChip(
                      Icons.trending_up,
                      _formatJobLevel(),
                      Colors.purple,
                    ),
                ],
              ),
              if (savedJob.deadline != null) ...[
                const SizedBox(height: 12),
                Row(
                  children: [
                    Icon(Icons.schedule, size: 14, color: Colors.grey[600]),
                    const SizedBox(width: 4),
                    Text(
                      'Hạn: ${DateFormat('dd/MM/yyyy').format(savedJob.deadline!)}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildChip(IconData icon, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
