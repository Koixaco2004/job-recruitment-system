import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'features/auth/presentation/pages/login_page.dart';
import 'features/auth/presentation/providers/auth_provider.dart';
import 'features/companies/presentation/providers/company_provider.dart';
import 'features/jobs/presentation/providers/job_provider.dart';
import 'features/jobs/presentation/providers/my_jobs_provider.dart';
import 'features/profile/presentation/providers/profile_provider.dart';
import 'features/employer/presentation/providers/employer_provider.dart';
import 'features/applications/presentation/providers/application_provider.dart';
import 'features/applications/presentation/providers/employer_application_provider.dart';
import 'features/headhunting/presentation/providers/headhunting_provider.dart';
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
        // My Jobs Provider
        ChangeNotifierProvider(create: (_) => di.sl<MyJobsProvider>()),
        // Company Provider
        ChangeNotifierProvider(create: (_) => di.sl<CompanyProvider>()),
        // Profile Provider
        ChangeNotifierProvider(create: (_) => di.sl<ProfileProvider>()),
        // Employer Provider
        ChangeNotifierProvider(create: (_) => di.sl<EmployerProvider>()),
        // Application Provider (Candidate)
        ChangeNotifierProvider(create: (_) => di.sl<ApplicationProvider>()),
        // Employer Application Provider
        ChangeNotifierProvider(create: (_) => di.sl<EmployerApplicationProvider>()),
        // Headhunting Provider
        ChangeNotifierProvider(create: (_) => di.sl<HeadhuntingProvider>()),
      ],
      child: MaterialApp(
        title: 'Recruitment App',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF0EA5E9), // Sky Blue
          ),
          useMaterial3: true,
          fontFamily: 'Roboto',
        ),
        home: const LoginPage(),
      ),
    );
  }
}
