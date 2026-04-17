import 'package:flutter/material.dart';
import '../../domain/entities/headhunting_candidate_entity.dart';
import 'package:provider/provider.dart';
import '../providers/headhunting_provider.dart';

class CandidateCard extends StatelessWidget {
  final HeadhuntingCandidateEntity candidate;
  final int? jobId;
  final VoidCallback? onTap;
  final bool showAppliedBadge;

  const CandidateCard({
    super.key,
    required this.candidate,
    this.jobId,
    this.onTap,
    this.showAppliedBadge = true,
  });

  String _formatCurrency(double? value) {
    if (value == null) return 'N/A';
    if (value >= 1000000) {
      final double result = value / 1000000;
      return result == result.toInt()
          ? '${result.toInt()} triệu'
          : '${result.toStringAsFixed(1).replaceAll('.0', '')} triệu';
    }
    return value.toString();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 4,
      shadowColor: theme.primaryColor.withOpacity(0.1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white,
                theme.primaryColor.withOpacity(0.02),
              ],
            ),
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Avatar with Premium Border
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: theme.primaryColor.withOpacity(0.2),
                        width: 2,
                      ),
                      image: candidate.avatarUrl != null
                          ? DecorationImage(
                              image: NetworkImage(candidate.avatarUrl!),
                              fit: BoxFit.cover,
                            )
                          : null,
                    ),
                    child: candidate.avatarUrl == null
                        ? Icon(Icons.person, size: 32, color: Colors.grey[400])
                        : null,
                  ),
                  const SizedBox(width: 16),
                  // Name and Position
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                candidate.fullName,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                            ),
                            if (jobId != null && showAppliedBadge)
                              Consumer<HeadhuntingProvider>(
                                builder: (context, provider, _) {
                                  if (provider.isApplied(candidate.id, jobId!)) {
                                    return Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: Colors.orange.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(4),
                                        border: Border.all(color: Colors.orange.withOpacity(0.3)),
                                      ),
                                      child: const Text(
                                        'Đã ứng tuyển',
                                        style: TextStyle(
                                          color: Colors.orange,
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    );
                                  }
                                  return const SizedBox();
                                },
                              ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          candidate.position ?? 'Chưa cập nhật vị trí',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 8),
                        // Match Score Badge
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.green[50],
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: Colors.green[200]!),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.flash_on,
                                  size: 14, color: Colors.green),
                              const SizedBox(width: 4),
                              Text(
                                'Khớp ${candidate.matchedSkillsCount} kỹ năng',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green[700],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Save Button (Heart)
                  Consumer<HeadhuntingProvider>(
                    builder: (context, provider, _) {
                      final isSaved = provider.isSaved(candidate.id);
                      return IconButton(
                        onPressed: () => provider.toggleSaveCandidate(candidate.id),
                        icon: Icon(
                          isSaved ? Icons.favorite : Icons.favorite_border,
                          color: isSaved ? Colors.red : Colors.grey[400],
                        ),
                        constraints: const BoxConstraints(),
                        padding: EdgeInsets.zero,
                        splashRadius: 20,
                      );
                    },
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Skills Tags
              if (candidate.skills.isNotEmpty) ...[
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: candidate.skills.take(5).map((skill) {
                    return Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: theme.primaryColor.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        skill.skillMetadata.canonicalName,
                        style: TextStyle(
                          fontSize: 12,
                          color: theme.primaryColor.withOpacity(0.7), // Fallback if direct color is needed, but sticking to opacity pattern
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),
              ],
              // Info Row: Experience & Salary
              Row(
                children: [
                  _buildInfoChip(
                    Icons.work_history_outlined,
                    '${candidate.yearsWorkingExperience} năm kinh nghiệm',
                    Colors.orange,
                  ),
                  const SizedBox(width: 12),
                  _buildInfoChip(
                    Icons.monetization_on_outlined,
                    '${_formatCurrency(candidate.salaryMin)}-${_formatCurrency(candidate.salaryMax)}',
                    Colors.blue,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String label, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.05),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: color,
                  fontWeight: FontWeight.w600,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
