import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/headhunting_provider.dart';
import '../widgets/candidate_card.dart';
import 'candidate_detail_page.dart';

class SuggestedCandidatesPage extends StatefulWidget {
  final int jobId;

  const SuggestedCandidatesPage({super.key, required this.jobId});

  @override
  State<SuggestedCandidatesPage> createState() => _SuggestedCandidatesPageState();
}

class _SuggestedCandidatesPageState extends State<SuggestedCandidatesPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<HeadhuntingProvider>().fetchSuggestedCandidates(widget.jobId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Ứng viên đề xuất',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: Consumer<HeadhuntingProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.errorMessage != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
                  const SizedBox(height: 16),
                  Text(
                    'Đã có lỗi xảy ra',
                    style: theme.textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Text(
                      provider.errorMessage!,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey),
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () => provider.fetchSuggestedCandidates(widget.jobId),
                    child: const Text('Thử lại'),
                  ),
                ],
              ),
            );
          }

          if (provider.suggestedCandidates.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.person_search_outlined, size: 80, color: Colors.grey[300]),
                  const SizedBox(height: 16),
                  Text(
                    'Chưa có ứng viên phù hợp',
                    style: theme.textTheme.titleMedium?.copyWith(color: Colors.grey[600]),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () => provider.fetchSuggestedCandidates(widget.jobId),
            child: ListView.builder(
              padding: const EdgeInsets.only(top: 8, bottom: 24),
              itemCount: provider.suggestedCandidates.length,
              itemBuilder: (context, index) {
                final candidate = provider.suggestedCandidates[index];
                return CandidateCard(
                  candidate: candidate,
                  jobId: widget.jobId,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CandidateDetailPage(
                          candidateId: candidate.id,
                          jobId: widget.jobId,
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          );
        },
      ),
    );
  }
}
