import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'features/auth/presentation/pages/login_page.dart';
import 'features/auth/presentation/providers/auth_provider.dart';
import 'features/jobs/presentation/providers/job_provider.dart';
import 'features/profile/presentation/providers/profile_provider.dart';
import 'injection_container.dart' as di;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Khởi tạo dependencies
  await di.init();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Auth Provider
        ChangeNotifierProvider(create: (_) => di.sl<AuthProvider>()),
        // Job Provider
        ChangeNotifierProvider(create: (_) => di.sl<JobProvider>()),
        // Profile Provider
        ChangeNotifierProvider(create: (_) => di.sl<ProfileProvider>()),
      ],
      child: MaterialApp(
        title: 'Recruitment App',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF6366F1), // Indigo color
          ),
          useMaterial3: true,
          fontFamily: 'Roboto',
        ),
        home: const LoginPage(),
      ),
    );
  }
}
