import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/employer_application_provider.dart';
import '../widgets/application_detail_drawer.dart';

class JobKanbanPage extends StatefulWidget {
  final int jobId;
  final String jobTitle;

  const JobKanbanPage({
    super.key,
    required this.jobId,
    required this.jobTitle,
  });

  @override
  State<JobKanbanPage> createState() => _JobKanbanPageState();
}

class _JobKanbanPageState extends State<JobKanbanPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchData();
    });
  }

  void _fetchData() {
    final provider = context.read<EmployerApplicationProvider>();
    provider.fetchKanbanBoard(widget.jobId);
    provider.fetchJobApplications(widget.jobId);
  }

  void _openDetail(int applicationId) {
    context.read<EmployerApplicationProvider>().fetchApplicationDetail(applicationId);
    _scaffoldKey.currentState?.openEndDrawer();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Quản lý ứng tuyển', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              Text(
                widget.jobTitle,
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.normal),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Bảng Kanban'),
              Tab(text: 'Danh sách'),
            ],
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _fetchData,
            ),
          ],
        ),
        endDrawer: const ApplicationDetailDrawer(),
        body: TabBarView(
          children: [
            _buildKanbanTab(),
            _buildListTab(),
          ],
        ),
      ),
    );
  }

  Color _getColumnColor(String statusId) {
    switch (statusId.toLowerCase()) {
      case 'applied':
        return Colors.blue;
      case 'shortlisted':
        return Colors.teal;
      case 'skill_test':
        return Colors.purple;
      case 'technical_interview':
        return Colors.indigo;
      case 'final_interview':
        return Colors.deepPurple;
      case 'hired':
      case 'accepted':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      default:
        return Colors.blueGrey;
    }
  }

  Color _darkenColor(Color color, [double amount = 0.15]) {
    final hsl = HSLColor.fromColor(color);
    final hslDark = hsl.withLightness((hsl.lightness - amount).clamp(0.0, 1.0));
    return hslDark.toColor();
  }

  Widget _buildKanbanTab() {
    return Consumer<EmployerApplicationProvider>(
      builder: (context, provider, child) {
        if (provider.isLoadingKanban) {
          return const Center(child: CircularProgressIndicator());
        }

        if (provider.errorMessage != null && provider.kanbanColumns.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Lỗi: ${provider.errorMessage}', style: const TextStyle(color: Colors.red)),
                ElevatedButton(onPressed: _fetchData, child: const Text('Thử lại')),
              ],
            ),
          );
        }

        if (provider.kanbanColumns.isEmpty) {
          return const Center(child: Text('Chưa có dữ liệu Kanban'));
        }

        return ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          itemCount: provider.kanbanColumns.length,
          itemBuilder: (context, index) {
            final column = provider.kanbanColumns[index];
            final color = _getColumnColor(column.id);
            final darkerColor = _darkenColor(color, 0.2);
            
            return Container(
              width: 280,
              margin: const EdgeInsets.only(right: 16, top: 8, bottom: 8),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.04),
                borderRadius: BorderRadius.circular(12),
                border: Border(
                  top: BorderSide(color: color, width: 4),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.03),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          child: Text(
                            column.title,
                            style: TextStyle(
                              fontWeight: FontWeight.bold, 
                              fontSize: 15,
                              color: darkerColor,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: color.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '${column.count}',
                            style: TextStyle(
                              color: _darkenColor(color, 0.3), 
                              fontSize: 12, 
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Divider(height: 1),
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.all(8),
                      itemCount: column.items.length,
                      itemBuilder: (context, itemIndex) {
                        final item = column.items[itemIndex];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 10),
                          elevation: 0.5,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                            side: BorderSide(color: Colors.grey[200]!, width: 0.5),
                          ),
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                            onTap: () => _openDetail(item.id),
                            title: Text(
                              item.candidate?.fullName ?? 'Ẩn danh',
                              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                            ),
                            subtitle: Padding(
                              padding: const EdgeInsets.only(top: 4),
                              child: Text(
                                item.candidate?.currentJobTitle ?? 'Ứng viên',
                                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                              ),
                            ),
                            trailing: item.matchScore != null 
                                ? Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: (item.matchScore! >= 70 ? Colors.green : (item.matchScore! >= 40 ? Colors.orange : Colors.red)).withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                        color: (item.matchScore! >= 70 ? Colors.green : (item.matchScore! >= 40 ? Colors.orange : Colors.red)).withValues(alpha: 0.3),
                                        width: 1,
                                      ),
                                    ),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          'Phù hợp',
                                          style: TextStyle(
                                            fontSize: 9, 
                                            color: (item.matchScore! >= 70 ? Colors.green : (item.matchScore! >= 40 ? Colors.orange : Colors.red)),
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                        Text(
                                          '${item.matchScore!.toInt()}%',
                                          style: TextStyle(
                                            fontSize: 13, 
                                            fontWeight: FontWeight.bold, 
                                            color: (item.matchScore! >= 70 ? Colors.green : (item.matchScore! >= 40 ? Colors.orange : Colors.red)),
                                          ),
                                        ),
                                      ],
                                    ),
                                  )
                                : null,
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildListTab() {
    return Consumer<EmployerApplicationProvider>(
      builder: (context, provider, child) {
        if (provider.isLoadingList && (provider.jobApplications?.data.isEmpty ?? true)) {
          return const Center(child: CircularProgressIndicator());
        }

        final applications = provider.jobApplications?.data ?? [];

        if (applications.isEmpty) {
          return const Center(child: Text('Chưa có ứng viên nào ứng tuyển'));
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: applications.length,
          itemBuilder: (context, index) {
            final app = applications[index];
            return Card(
              child: ListTile(
                onTap: () => _openDetail(app.id),
                leading: CircleAvatar(
                  backgroundImage: app.candidate?.avatarUrl != null ? NetworkImage(app.candidate!.avatarUrl!) : null,
                  child: app.candidate?.avatarUrl == null ? const Icon(Icons.person) : null,
                ),
                title: Text(app.candidate?.fullName ?? 'Ứng viên #${app.id}'),
                subtitle: Text('Trạng thái: ${app.status} • Ngày nộp: ${app.appliedAt.day}/${app.appliedAt.month}'),
                trailing: const Icon(Icons.chevron_right),
              ),
            );
          },
        );
      },
    );
  }
}
