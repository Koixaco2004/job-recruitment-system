import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/employer_provider.dart';
import '../widgets/add_member_dialog.dart';
import 'package:intl/intl.dart';

class MemberManagementPage extends StatefulWidget {
  const MemberManagementPage({super.key});

  @override
  State<MemberManagementPage> createState() => _MemberManagementPageState();
}

class _MemberManagementPageState extends State<MemberManagementPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<EmployerProvider>().fetchMembers();
    });
  }

  @override
  Widget build(BuildContext context) {
    final employerProvider = context.watch<EmployerProvider>();
    final members = employerProvider.members;
    final isLoading = employerProvider.isMemberLoading;
    final isAdmin = employerProvider.employer?.isAdminCompany ?? false;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Quản lý nhân sự'),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: _buildBody(employerProvider, isAdmin),
      floatingActionButton: isAdmin
          ? FloatingActionButton(
              onPressed: () => _showAddMemberDialog(context),
              child: const Icon(Icons.add),
              tooltip: 'Thêm thành viên',
            )
          : null,
    );
  }

  Widget _buildBody(EmployerProvider provider, bool isAdmin) {
    if (provider.isMemberLoading && provider.members.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (provider.members.isEmpty) {
      return RefreshIndicator(
        onRefresh: provider.fetchMembers,
        child: ListView(
          children: [
            SizedBox(height: MediaQuery.of(context).size.height * 0.2),
            const Center(
              child: Column(
                children: [
                  Icon(Icons.people_outline, size: 80, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'Chưa có thành viên nào',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: provider.fetchMembers,
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: provider.members.length,
        separatorBuilder: (context, index) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final member = provider.members[index];
          return _buildMemberCard(context, member, provider, isAdmin);
        },
      ),
    );
  }

  Widget _buildMemberCard(BuildContext context, dynamic member, EmployerProvider provider, bool isAdmin) {
    final isMemberAdmin = member.isAdminCompany;
    final role = isMemberAdmin ? 'ADMIN' : 'RECRUITER';
    final roleColor = isMemberAdmin ? Colors.blue[700] : Colors.green[700];
    final roleBg = isMemberAdmin ? Colors.blue[50] : Colors.green[50];

    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            CircleAvatar(
              radius: 25,
              backgroundColor: Colors.grey[200],
              backgroundImage: member.avatarUrl != null && member.avatarUrl!.isNotEmpty
                  ? NetworkImage(member.avatarUrl!)
                  : null,
              child: member.avatarUrl == null || member.avatarUrl!.isEmpty
                  ? const Icon(Icons.person, color: Colors.grey)
                  : null,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    member.fullName,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  Text(
                    member.user?.email ?? '-',
                    style: TextStyle(color: Colors.grey[600], fontSize: 14),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: roleBg,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      role,
                      style: TextStyle(
                        color: roleColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 11,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            if (isAdmin)
              IconButton(
                icon: const Icon(Icons.delete_outline, color: Colors.red),
                onPressed: () => _confirmRemoveMember(context, member, provider),
              ),
          ],
        ),
      ),
    );
  }

  void _confirmRemoveMember(BuildContext context, dynamic member, EmployerProvider provider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận gỡ'),
        content: Text('Bạn có chắc chắn muốn gỡ ${member.fullName} khỏi công ty?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              final success = await provider.removeMember(member.id);
              if (success && mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Đã gỡ thành viên thành công')),
                );
              } else if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(provider.errorMessage ?? 'Có lỗi xảy ra')),
                );
              }
            },
            child: const Text('Gỡ', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showAddMemberDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const AddMemberDialog(),
    );
  }
}
