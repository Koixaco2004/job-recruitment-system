import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../domain/entities/employer_invitation_entity.dart';
import '../providers/headhunting_provider.dart';
import 'candidate_detail_page.dart';
import '../../../applications/presentation/pages/job_kanban_page.dart';

class EmployerInvitationListPage extends StatefulWidget {
  const EmployerInvitationListPage({super.key});

  @override
  State<EmployerInvitationListPage> createState() => _EmployerInvitationListPageState();
}

class _EmployerInvitationListPageState extends State<EmployerInvitationListPage> {
  String _selectedStatus = 'all';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<HeadhuntingProvider>().fetchEmployerInvitations();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Thư mời đã gửi'),
        elevation: 0,
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          _buildFilterBar(),
          Expanded(
            child: Consumer<HeadhuntingProvider>(
              builder: (context, provider, child) {
                if (provider.isLoadingEmployerInvitations) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (provider.employerInvitationError != null) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.error_outline, size: 48, color: Colors.red[300]),
                          const SizedBox(height: 16),
                          Text(
                            provider.employerInvitationError!,
                            textAlign: TextAlign.center,
                            style: const TextStyle(color: Colors.red),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () => provider.fetchEmployerInvitations(),
                            child: const Text('Thử lại'),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                final filteredList = _selectedStatus == 'all'
                    ? provider.employerInvitations
                    : provider.employerInvitations.where((i) => i.status == _selectedStatus).toList();

                if (filteredList.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.mail_outline, size: 64, color: Colors.grey[300]),
                        const SizedBox(height: 16),
                        Text(
                          'Không tìm thấy thư mời nào',
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: () => provider.fetchEmployerInvitations(),
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: filteredList.length,
                    itemBuilder: (context, index) {
                      final invitation = filteredList[index];
                      return _buildInvitationCard(context, invitation);
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterBar() {
    final filters = [
      {'label': 'Tất cả', 'value': 'all'},
      {'label': 'Đang chờ', 'value': 'pending'},
      {'label': 'Đã chấp nhận', 'value': 'accepted'},
      {'label': 'Đã từ chối', 'value': 'declined'},
    ];

    return Container(
      height: 60,
      color: Colors.white,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        itemCount: filters.length,
        itemBuilder: (context, index) {
          final filter = filters[index];
          final isSelected = _selectedStatus == filter['value'];

          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: Text(filter['label']!),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  _selectedStatus = filter['value']!;
                });
              },
              backgroundColor: Colors.white,
              selectedColor: Theme.of(context).primaryColor.withOpacity(0.1),
              checkmarkColor: Theme.of(context).primaryColor,
              labelStyle: TextStyle(
                color: isSelected ? Theme.of(context).primaryColor : Colors.grey[700],
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
              side: BorderSide(
                color: isSelected ? Theme.of(context).primaryColor : Colors.grey[300]!,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildInvitationCard(BuildContext context, EmployerInvitationEntity invitation) {
    Color statusColor;
    String statusText;
    IconData statusIcon;

    switch (invitation.status) {
      case 'accepted':
        statusColor = Colors.green;
        statusText = 'Đã chấp nhận';
        statusIcon = Icons.check_circle;
        break;
      case 'declined':
        statusColor = Colors.red;
        statusText = 'Đã từ chối';
        statusIcon = Icons.cancel;
        break;
      default:
        statusColor = Colors.orange;
        statusText = 'Đang chờ';
        statusIcon = Icons.access_time_filled;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: InkWell(
        onTap: () => _handleNavigation(context, invitation),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundImage: invitation.candidate.avatarUrl != null 
                        ? NetworkImage(invitation.candidate.avatarUrl!) 
                        : null,
                    child: invitation.candidate.avatarUrl == null 
                        ? const Icon(Icons.person) 
                        : null,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          invitation.candidate.fullName,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        if (invitation.candidate.position != null)
                          Text(
                            invitation.candidate.position!,
                            style: TextStyle(color: Colors.grey[600], fontSize: 13),
                          ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(statusIcon, size: 14, color: statusColor),
                        const SizedBox(width: 4),
                        Text(
                          statusText,
                          style: TextStyle(color: statusColor, fontSize: 12, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const Divider(height: 24),
              Row(
                children: [
                  const Icon(Icons.work_outline, size: 16, color: Colors.blueGrey),
                  const SizedBox(width: 8),
                  const Text('Công việc: ', style: TextStyle(color: Colors.grey, fontSize: 13)),
                  Expanded(
                    child: Text(
                      invitation.job.title,
                      style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.calendar_today_outlined, size: 16, color: Colors.blueGrey),
                  const SizedBox(width: 8),
                  const Text('Ngày gửi: ', style: TextStyle(color: Colors.grey, fontSize: 13)),
                  Text(
                    '${invitation.createdAt.day}/${invitation.createdAt.month}/${invitation.createdAt.year}',
                    style: const TextStyle(fontSize: 13),
                  ),
                ],
              ),
              if (invitation.status == 'accepted') ...[
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Center(
                    child: Text(
                      'Nhấn để xem trong bảng Kanban',
                      style: TextStyle(color: Colors.blue, fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  void _handleNavigation(BuildContext context, EmployerInvitationEntity invitation) {
    if (invitation.status == 'accepted') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => JobKanbanPage(
            jobId: invitation.jobId,
            jobTitle: invitation.job.title,
          ),
        ),
      );
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => CandidateDetailPage(
            candidateId: invitation.candidateId,
            jobId: invitation.jobId,
          ),
        ),
      );
    }
  }
}
