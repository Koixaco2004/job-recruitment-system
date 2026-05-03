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

          return Column(
            children: [
              if (provider.appliedWeights != null)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  color: Colors.white,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.info_outline, size: 16, color: Colors.blue),
                          const SizedBox(width: 8),
                          Text(
                            'Tìm thấy ${provider.suggestedTotal} ứng viên phù hợp nhất',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            _buildWeightBadge('Kỹ năng', provider.appliedWeights!.skillWeight),
                            _buildWeightBadge('KN', provider.appliedWeights!.experienceWeight),
                            _buildWeightBadge('Lương', provider.appliedWeights!.salaryWeight),
                            _buildWeightBadge('Cấp bậc', provider.appliedWeights!.levelWeight),
                            _buildWeightBadge('Địa điểm', provider.appliedWeights!.locationWeight),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              Expanded(
                child: RefreshIndicator(
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
                ),
              ),
            ],
          );
        },
      ),
    );
  }
  
  Widget _buildWeightBadge(String label, int weight) {
    if (weight <= 0) return const SizedBox();
    return Container(
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Text(
        '$label: $weight%',
        style: TextStyle(fontSize: 10, color: Colors.grey[700]),
      ),
    );
  }
}
