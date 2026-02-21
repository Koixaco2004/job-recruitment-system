import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../features/companies/presentation/pages/companies_page.dart';
import '../../features/jobs/presentation/pages/home_page.dart';
import '../../features/jobs/presentation/pages/my_jobs_page.dart';
import '../../features/jobs/presentation/providers/my_jobs_provider.dart';
import '../../features/profile/presentation/pages/profile_page.dart';
import '../../features/profile/presentation/providers/profile_provider.dart';

/// Màn hình chính với Bottom Navigation Bar
class MainPage extends StatefulWidget {
  const MainPage({super.key});

  /// Chuyển tab từ child widget
  static void switchTab(BuildContext context, int index) {
    final state = context.findAncestorStateOfType<_MainPageState>();
    state?._onTabTapped(index);
  }

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _currentIndex = 0;

  final List<Widget> _pages = const [
    HomePage(),
    CompaniesPage(),
    MyJobsPage(),
    ProfilePage(),
  ];

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });

    // Auto-refresh data khi chuyển sang tab "Việc của tôi"
    if (index == 2) {
      final profileProvider = context.read<ProfileProvider>();
      final myJobsProvider = context.read<MyJobsProvider>();
      final candidateId = profileProvider.profile?.candidateId ?? 1;
      myJobsProvider.fetchSavedJobs(candidateId);
      myJobsProvider.fetchApplications(candidateId);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _pages),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Theme.of(context).primaryColor,
        unselectedItemColor: Colors.grey,
        selectedFontSize: 12,
        unselectedFontSize: 12,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Khám phá'),
          BottomNavigationBarItem(icon: Icon(Icons.business), label: 'Công ty'),
          BottomNavigationBarItem(
            icon: Icon(Icons.work_history),
            label: 'Việc của tôi',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Hồ sơ'),
        ],
      ),
    );
  }
}
