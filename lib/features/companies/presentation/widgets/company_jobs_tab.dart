import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../jobs/presentation/pages/job_detail_page.dart';
import '../../../jobs/presentation/widgets/job_card.dart';
import '../providers/company_provider.dart';

/// Tab hiển thị danh sách việc làm của công ty
class CompanyJobsTab extends StatelessWidget {
  final String companySlug;

  const CompanyJobsTab({super.key, required this.companySlug});

  @override
  Widget build(BuildContext context) {
    return Consumer<CompanyProvider>(
      builder: (context, provider, child) {
        if (provider.isLoadingJobs) {
          return const Center(child: CircularProgressIndicator());
        }

        if (provider.jobsError != null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 64, color: Colors.red),
                const SizedBox(height: 16),
                Text(provider.jobsError!),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => provider.fetchCompanyJobs(companySlug),
                  child: const Text('Thử lại'),
                ),
              ],
            ),
          );
        }

        if (provider.companyJobs.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.work_off, size: 64, color: Colors.grey[400]),
                const SizedBox(height: 16),
                Text(
                  'Chưa có việc làm nào',
                  style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () => provider.fetchCompanyJobs(companySlug),
          child: ListView.builder(
            padding: const EdgeInsets.only(top: 8, bottom: 16),
            itemCount: provider.companyJobs.length,
            itemBuilder: (context, index) {
              final job = provider.companyJobs[index];
              return JobCard(
                job: job,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => JobDetailPage(job: job),
                    ),
                  );
                },
              );
            },
          ),
        );
      },
    );
  }
}
