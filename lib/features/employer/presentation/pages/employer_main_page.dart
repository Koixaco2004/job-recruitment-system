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
import 'package:test1/features/headhunting/presentation/providers/headhunting_provider.dart';
import 'package:test1/features/headhunting/presentation/pages/candidate_search_page.dart';
import 'package:test1/features/headhunting/presentation/pages/employer_invitation_list_page.dart';
import 'package:test1/features/headhunting/presentation/pages/employer_saved_candidates_page.dart';
import 'package:test1/features/notifications/presentation/providers/notification_provider.dart';
import 'package:test1/features/notifications/presentation/widgets/notification_bell.dart';
import 'package:test1/features/auth/presentation/widgets/verification_banner.dart';
import 'package:test1/features/employer/presentation/pages/member_management_page.dart';
import 'package:test1/features/auth/presentation/pages/change_password_page.dart';
import 'package:test1/features/headhunting/presentation/pages/employer_dashboard_page.dart';
import 'package:test1/features/headhunting/presentation/providers/employer_dashboard_provider.dart';
import 'package:test1/features/monetization/presentation/pages/pricing_page.dart';
import 'package:test1/features/monetization/presentation/pages/topup_page.dart';
import 'package:test1/features/monetization/presentation/providers/monetization_provider.dart';

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
      final notificationProvider = context.read<NotificationProvider>();
      notificationProvider.initSocket();
      notificationProvider.fetchUnreadCount();
      notificationProvider.fetchNotifications(refresh: true);
    });
  }

  Future<void> _checkStatus() async {
    final employerProvider = context.read<EmployerProvider>();
    await employerProvider.getProfile();
    
    if (mounted) {
      context.read<MonetizationProvider>().fetchSubscriptionStatus();
      context.read<MonetizationProvider>().fetchCreditBalance();
      context.read<JobProvider>().fetchEmployerJobs(status: 'published');
      context.read<HeadhuntingProvider>().fetchEmployerInvitations();
      context.read<HeadhuntingProvider>().fetchSavedCandidates();
      context.read<EmployerDashboardProvider>().fetchDashboardStats();
    }
    
    if (mounted) {
      if (employerProvider.employer?.companyId == null) {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => const CompanySetupPage(),
            fullscreenDialog: true,
          ),
        ).then((_) => _checkStatus());
      }
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    if (index == 0) {
      _checkStatus();
    }
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
      EmployerDashboardPage(onSwitchTab: _onItemTapped),
      const MyJobsPage(),
      const CandidateSearchPage(),
      _buildProfileTab(context),
    ];

    return Scaffold(
      body: Column(
        children: [
          const VerificationBanner(),
          Expanded(child: pages[_selectedIndex]),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: 'Tổng quan'),
          BottomNavigationBarItem(icon: Icon(Icons.work), label: 'Tin tuyển dụng'),
          BottomNavigationBarItem(icon: Icon(Icons.person_search), label: 'Tìm ứng viên'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Hồ sơ'),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blue[800],
        unselectedItemColor: Colors.grey[600],
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
        onTap: _onItemTapped,
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
            leading: Icon(Icons.people_outline, color: Theme.of(context).primaryColor),
            title: const Text('Quản lý nhân sự'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const MemberManagementPage()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.workspace_premium, color: Colors.amber),
            title: const Text('Nâng cấp VIP'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const PricingPage()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.toll, color: Colors.blue),
            title: const Text('Nạp Credit'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const TopupPage()),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.lock_outline, color: Theme.of(context).primaryColor),
            title: const Text('Đổi mật khẩu'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const ChangePasswordPage()),
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
              context.read<NotificationProvider>().disconnectSocket();
              context.read<EmployerProvider>().clear(); 
              context.read<MonetizationProvider>().clear();
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
