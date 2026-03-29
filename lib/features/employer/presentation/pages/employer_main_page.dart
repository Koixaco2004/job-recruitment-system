import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:test1/features/auth/presentation/providers/auth_provider.dart';
import 'package:test1/features/auth/presentation/pages/login_page.dart';

class EmployerMainPage extends StatelessWidget {
  const EmployerMainPage({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final user = authProvider.user;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Nhà tuyển dụng'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
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
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.business_center,
              size: 80,
              color: Colors.blue,
            ),
            const SizedBox(height: 16),
            Text(
              'Chào mừng, ${user?.fullName ?? user?.email ?? 'Nhà tuyển dụng'}!',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Đây là giao diện dành riêng cho Nhà tuyển dụng.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                // Future employer features
              },
              child: const Text('Quản lý tin tuyển dụng'),
            ),
          ],
        ),
      ),
    );
  }
}
