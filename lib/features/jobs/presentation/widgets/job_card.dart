import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../profile/presentation/providers/profile_provider.dart';
import '../../domain/entities/job_post_entity.dart';
import '../providers/my_jobs_provider.dart';

/// Widget hiển thị thông tin job dưới dạng card
class JobCard extends StatelessWidget {
  final JobPostEntity job;
  final VoidCallback? onTap;

  const JobCard({super.key, required this.job, this.onTap});

  String _formatPriceValue(int? value) {
    if (value == null) return '';
    if (value >= 1000000) {
      final double result = value / 1000000;
      return result == result.toInt() 
          ? '${result.toInt()} triệu' 
          : '${result.toStringAsFixed(1).replaceAll('.0', '')} triệu';
    } else if (value >= 1000) {
      return '${value ~/ 1000} ngàn';
    }
    return value.toString();
  }

  String _formatSalary() {
    if (job.salaryType == 'negotiable' || (job.salaryMin == null && job.salaryMax == null)) {
      return 'Thỏa thuận';
    }

    if (job.salaryMin != null && job.salaryMax != null) {
      return '${_formatPriceValue(job.salaryMin!)}-${_formatPriceValue(job.salaryMax!)}';
    } else if (job.salaryMin != null) {
      return 'Từ ${_formatPriceValue(job.salaryMin!)}';
    }
    return 'Thỏa thuận';
  }

  String _formatJobType() {
    switch (job.jobType) {
      case 'fulltime':
        return 'Full-time';
      case 'parttime':
        return 'Part-time';
      case 'remote':
        return 'Remote';
      case 'freelance':
        return 'Freelance';
      default:
        return job.jobType;
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
                      image: job.companyLogo != null
                          ? DecorationImage(
                              image: NetworkImage(job.companyLogo!),
                              fit: BoxFit.cover,
                            )
                          : null,
                    ),
                    child: job.companyLogo == null
                        ? const Icon(Icons.business, color: Colors.grey)
                        : null,
                  ),
                  const SizedBox(width: 12),
                  // Company name + priority badge
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                job.companyName,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black87,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (job.isPriority)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.orange[100],
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: const Text(
                                  'HOT',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.orange,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(
                              Icons.location_on,
                              size: 15,
                              color: Theme.of(context).primaryColor,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              job.cityName,
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey[700],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Icon(
                              Icons.category,
                              size: 15,
                              color: Theme.of(context).primaryColor,
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                job.industryName,
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey[700],
                                  fontWeight: FontWeight.w500,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  // Heart button
                  Consumer<MyJobsProvider>(
                    builder: (context, myJobsProvider, child) {
                      final isSaved = myJobsProvider.isJobSaved(job.jobPostId);
                      return IconButton(
                        icon: Icon(
                          isSaved ? Icons.favorite : Icons.favorite_border,
                          color: isSaved ? Colors.red : Colors.grey,
                        ),
                        onPressed: () async {
                          final profileProvider = context
                              .read<ProfileProvider>();
                          final candidateId =
                              profileProvider.profile?.candidateId ?? 1;

                          if (isSaved) {
                            // Unsave
                            final success = await myJobsProvider
                                .unsaveJobByJobPostId(
                                  candidateId: candidateId,
                                  jobPostId: job.jobPostId,
                                );
                            if (context.mounted && success) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Đã bỏ lưu việc làm'),
                                  duration: Duration(seconds: 1),
                                ),
                              );
                            }
                          } else {
                            // Save
                            final success = await myJobsProvider.saveJob(
                              candidateId: candidateId,
                              jobPostId: job.jobPostId,
                            );
                            if (context.mounted && success) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Đã lưu việc làm'),
                                  duration: Duration(seconds: 1),
                                ),
                              );
                            }
                          }
                        },
                        tooltip: isSaved ? 'Bỏ lưu' : 'Lưu việc làm',
                      );
                    },
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Job title
              Text(
                job.title,
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
                  _buildChip(Icons.work_outline, _formatJobType(), Colors.blue),
                ],
              ),
              const SizedBox(height: 12),
              // Footer: Stats
              Row(
                children: [
                  Icon(Icons.visibility, size: 14, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text(
                    '${job.viewCount}',
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                  const SizedBox(width: 16),
                  Icon(Icons.people, size: 14, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text(
                    '${job.applicationCount} ứng tuyển',
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                  const Spacer(),
                  Text(
                    'Hạn: ${DateFormat('dd/MM').format(job.deadline)}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
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
