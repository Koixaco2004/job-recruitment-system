import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:test1/features/auth/presentation/providers/auth_provider.dart';
import 'package:test1/features/employer/presentation/providers/employer_provider.dart';
import 'package:test1/features/employer/presentation/pages/company_setup_page.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:test1/features/auth/presentation/pages/login_page.dart';
import 'package:test1/features/employer/presentation/pages/employer_edit_profile_page.dart';
import 'package:test1/features/employer/presentation/pages/employer_company_edit_page.dart';
import 'package:test1/features/jobs/presentation/providers/job_provider.dart';
import 'package:test1/features/jobs/presentation/pages/my_jobs_page.dart';

class EmployerMainPage extends StatefulWidget {
  const EmployerMainPage({super.key});

  @override
  State<EmployerMainPage> createState() => _EmployerMainPageState();
}

class _EmployerMainPageState extends State<EmployerMainPage> {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkStatus();
    });
  }

  Future<void> _checkStatus() async {
    final employerProvider = context.read<EmployerProvider>();
    await employerProvider.getProfile();
    
    // Fetch job stats
    if (mounted) {
      context.read<JobProvider>().fetchEmployerJobs(status: 'published');
    }
    
    if (mounted) {
      if (employerProvider.employer?.companyId == null) {
        // Force setup
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => const CompanySetupPage(),
            fullscreenDialog: true,
          ),
        ).then((_) => _checkStatus()); // Re-check after setup page pops
      }
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final employerProvider = context.watch<EmployerProvider>();
    final isLoading = employerProvider.isLoading;
    final employer = employerProvider.employer;

    if (isLoading && employer == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final List<Widget> pages = [
      _buildDashboardTab(employer),
      const MyJobsPage(),
      _buildProfileTab(context),
    ];

    return Scaffold(
      body: pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: 'Tổng quan'),
          BottomNavigationBarItem(icon: Icon(Icons.work), label: 'Tin tuyển dụng'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Hồ sơ'),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blue[800],
        onTap: _onItemTapped,
      ),
    );
  }

  Widget _buildDashboardTab(dynamic employer) {
    final jobProvider = context.watch<JobProvider>();
    return Scaffold(
      appBar: AppBar(title: const Text('Dashboard')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
             Card(
              color: Colors.blue[50],
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundColor: Colors.blue[100],
                      child: const Icon(Icons.business, size: 30, color: Colors.blue),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            employer?.company?.name ?? 'Chưa thiết lập công ty',
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          Text(employer?.fullName ?? 'HR'),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Text('Chào mừng bạn quay lại!', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            const Text('Quản lý các hoạt động tuyển dụng của bạn ngay tại đây.'),
            const SizedBox(height: 32),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              children: [
                _buildStatCard(
                    'Tin đã đăng', 
                    jobProvider.getEmployerJobsByStatus('published').length.toString(), 
                    Icons.post_add, 
                    Colors.blue, 
                    onTap: () => _onItemTapped(1)
                ),
                _buildStatCard('Ứng viên mới', '0', Icons.people, Colors.green),
                _buildStatCard('Phỏng vấn', '0', Icons.event_available, Colors.orange),
                _buildStatCard('Thông báo', '0', Icons.notifications, Colors.purple),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String count, IconData icon, Color color, {VoidCallback? onTap}) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: color, size: 30),
              const SizedBox(height: 8),
              Text(count, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              Text(title, style: const TextStyle(fontSize: 12, color: Colors.grey)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileTab(BuildContext context) {
    final authProvider = context.read<AuthProvider>();
    final employerProvider = context.watch<EmployerProvider>();
    final employer = employerProvider.employer;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Hồ sơ nhà tuyển dụng'),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: ListView(
        children: [
          const SizedBox(height: 20),
          Center(
            child: CircleAvatar(
              radius: 50,
              backgroundColor: Colors.blue[50],
              backgroundImage: employer?.avatarUrl != null && employer!.avatarUrl!.isNotEmpty
                  ? CachedNetworkImageProvider(employer.avatarUrl!)
                  : null,
              child: employer?.avatarUrl == null || employer!.avatarUrl!.isEmpty
                  ? const Icon(Icons.person, size: 50, color: Colors.blue)
                  : null,
            ),
          ),
          const SizedBox(height: 12),
          Center(
            child: Text(
              employer?.fullName ?? authProvider.user?.fullName ?? '-',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 30),
          ListTile(
            leading: Icon(Icons.person_outline, color: Theme.of(context).primaryColor),
            title: const Text('Chỉnh sửa hồ sơ'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const EmployerEditProfilePage()),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.business_outlined, color: Theme.of(context).primaryColor),
            title: const Text('Thông tin công ty'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const EmployerCompanyEditPage()),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.settings_outlined, color: Theme.of(context).primaryColor),
            title: const Text('Cài đặt tài khoản'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              // Future: Link to settings page
            },
          ),
          const Divider(indent: 16, endIndent: 16),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text('Đăng xuất', style: TextStyle(color: Colors.red)),
            onTap: () async {
              context.read<EmployerProvider>().clear(); // Clear local employer state
              await authProvider.logout();
              if (context.mounted) {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => const LoginPage()),
                  (route) => false,
                );
              }
            },
          ),
        ],
      ),
    );
  }
}
