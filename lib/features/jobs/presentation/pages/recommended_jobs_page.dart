import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/recommended_jobs_provider.dart';
import '../widgets/job_card.dart';
import 'job_detail_page.dart';

class RecommendedJobsPage extends StatefulWidget {
  const RecommendedJobsPage({super.key});

  @override
  State<RecommendedJobsPage> createState() => _RecommendedJobsPageState();
}

class _RecommendedJobsPageState extends State<RecommendedJobsPage> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<RecommendedJobsProvider>().fetchRecommendedJobs(refresh: true);
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      context.read<RecommendedJobsProvider>().fetchRecommendedJobs();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text(
          'Việc làm gợi ý cho bạn',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black87,
      ),
      body: Consumer<RecommendedJobsProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading && provider.recommendedJobs.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.errorMessage != null && provider.recommendedJobs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
                  const SizedBox(height: 16),
                  Text(
                    provider.errorMessage!,
                    style: const TextStyle(color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => provider.fetchRecommendedJobs(refresh: true),
                    child: const Text('Thử lại'),
                  ),
                ],
              ),
            );
          }

          if (provider.recommendedJobs.isEmpty) {
            return RefreshIndicator(
              onRefresh: () => provider.fetchRecommendedJobs(refresh: true),
              child: ListView(
                children: [
                  SizedBox(height: MediaQuery.of(context).size.height * 0.2),
                  const Center(
                    child: Column(
                      children: [
                        Icon(Icons.work_off_outlined, size: 80, color: Colors.grey),
                        SizedBox(height: 16),
                        Text(
                          'Chưa có việc làm gợi ý nào',
                          style: TextStyle(color: Colors.grey, fontSize: 16),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () => provider.fetchRecommendedJobs(refresh: true),
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: provider.recommendedJobs.length + (provider.hasMore ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == provider.recommendedJobs.length) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }

                final job = provider.recommendedJobs[index];
                return JobCard(
                  job: job,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => JobDetailPage(job: job)),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
