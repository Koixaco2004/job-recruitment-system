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
          padding: const EdgeInsets.all(16),
          itemCount: provider.kanbanColumns.length,
          itemBuilder: (context, index) {
            final column = provider.kanbanColumns[index];
            return Container(
              width: 280,
              margin: const EdgeInsets.only(right: 16),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
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
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.blue[100],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '${column.count}',
                            style: TextStyle(color: Colors.blue[800], fontSize: 12, fontWeight: FontWeight.bold),
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
                          margin: const EdgeInsets.only(bottom: 8),
                          child: ListTile(
                            onTap: () => _openDetail(item.id),
                            title: Text(item.candidate?.fullName ?? 'Ẩn danh'),
                            subtitle: Text(item.candidate?.currentJobTitle ?? 'Ứng viên'),
                            trailing: item.matchScore != null 
                                ? Container(
                                    padding: const EdgeInsets.all(4),
                                    decoration: BoxDecoration(
                                      color: Colors.green[50],
                                      shape: BoxShape.circle,
                                    ),
                                    child: Text(
                                      '${item.matchScore!.toInt()}',
                                      style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.green),
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
