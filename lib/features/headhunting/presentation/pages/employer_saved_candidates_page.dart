import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/headhunting_provider.dart';
import '../widgets/candidate_card.dart';
import 'candidate_detail_page.dart';

class EmployerSavedCandidatesPage extends StatefulWidget {
  const EmployerSavedCandidatesPage({super.key});

  @override
  State<EmployerSavedCandidatesPage> createState() => _EmployerSavedCandidatesPageState();
}

class _EmployerSavedCandidatesPageState extends State<EmployerSavedCandidatesPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<HeadhuntingProvider>().fetchSavedCandidates();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Talent Pool'),
        elevation: 0,
        backgroundColor: theme.primaryColor,
        foregroundColor: Colors.white,
      ),
      body: Consumer<HeadhuntingProvider>(
        builder: (context, provider, child) {
          if (provider.isLoadingSavedCandidates) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.savedCandidatesError != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
                  const SizedBox(height: 16),
                  Text(
                    provider.savedCandidatesError!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.red),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => provider.fetchSavedCandidates(),
                    child: const Text('Thử lại'),
                  ),
                ],
              ),
            );
          }

          final savedCandidates = provider.savedCandidates;

          if (savedCandidates.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.favorite_border, size: 80, color: Colors.grey[300]),
                  const SizedBox(height: 24),
                  const Text(
                    'Chưa có ứng viên nào được lưu',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black54,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Lưu các ứng viên tiềm năng để xem lại sau',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () => provider.fetchSavedCandidates(),
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: savedCandidates.length,
              itemBuilder: (context, index) {
                final savedCandidate = savedCandidates[index];
                final candidate = savedCandidate.candidate;

                if (candidate == null) return const SizedBox();

                return CandidateCard(
                  candidate: candidate,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CandidateDetailPage(
                          candidateId: candidate.id,
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
