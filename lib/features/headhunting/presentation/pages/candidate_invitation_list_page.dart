import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/headhunting_provider.dart';
import '../../domain/entities/candidate_invitation_entity.dart';
import 'package:cached_network_image/cached_network_image.dart';

class CandidateInvitationListPage extends StatefulWidget {
  const CandidateInvitationListPage({super.key});

  @override
  State<CandidateInvitationListPage> createState() => _CandidateInvitationListPageState();
}

class _CandidateInvitationListPageState extends State<CandidateInvitationListPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<HeadhuntingProvider>().fetchCandidateInvitations();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Thư mời nhận được'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0.5,
      ),
      body: Consumer<HeadhuntingProvider>(
        builder: (context, provider, child) {
          if (provider.isLoadingInvitations && provider.candidateInvitations.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.candidateInvitationError != null && provider.candidateInvitations.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
                  const SizedBox(height: 16),
                  Text(provider.candidateInvitationError!, style: const TextStyle(color: Colors.red)),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => provider.fetchCandidateInvitations(),
                    child: const Text('Thử lại'),
                  ),
                ],
              ),
            );
          }

          if (provider.candidateInvitations.isEmpty) {
            return RefreshIndicator(
              onRefresh: () => provider.fetchCandidateInvitations(),
              child: ListView(
                children: [
                   SizedBox(height: MediaQuery.of(context).size.height * 0.3),
                   const Center(
                    child: Column(
                      children: [
                        Icon(Icons.mark_email_unread_outlined, size: 80, color: Colors.grey),
                        SizedBox(height: 16),
                        Text('Bạn chưa có thư mời nào', style: TextStyle(color: Colors.grey, fontSize: 16)),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () => provider.fetchCandidateInvitations(),
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: provider.candidateInvitations.length,
              itemBuilder: (context, index) {
                final invitation = provider.candidateInvitations[index];
                return _buildInvitationCard(context, invitation, provider);
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildInvitationCard(BuildContext context, CandidateInvitationEntity invitation, HeadhuntingProvider provider) {
    final bool isPending = invitation.status == 'pending';
    final bool isAccepted = invitation.status == 'accepted';
    final bool isDeclined = invitation.status == 'declined';
    
    final currencyFormat = NumberFormat.currency(locale: 'vi_VN', symbol: invitation.job.currency ?? 'VND');
    final String salaryRange = "${currencyFormat.format(invitation.job.salaryMin).split(',')[0]} - ${currencyFormat.format(invitation.job.salaryMax).split(',')[0]}";

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey[200]!),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: CachedNetworkImage(
                    imageUrl: invitation.job.company.logoUrl ?? '',
                    width: 50,
                    height: 50,
                    placeholder: (context, url) => Container(color: Colors.grey[100]),
                    errorWidget: (context, url, error) => Container(
                      color: Colors.blue[50],
                      child: const Icon(Icons.business, color: Colors.blue),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        invitation.job.title,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        invitation.job.company.name,
                        style: TextStyle(color: Colors.grey[600], fontSize: 14),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                _buildStatusBadge(invitation.status),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Lời nhắn từ nhà tuyển dụng:',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.black54),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    invitation.message,
                    style: const TextStyle(fontSize: 14, fontStyle: FontStyle.italic),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.payments_outlined, size: 16, color: Colors.green[700]),
                const SizedBox(width: 4),
                Text(salaryRange, style: TextStyle(color: Colors.green[700], fontWeight: FontWeight.w600)),
                const Spacer(),
                Text(
                  DateFormat('dd/MM/yyyy').format(invitation.createdAt),
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ],
            ),
            if (isPending) ...[
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: provider.isActionInProgress
                          ? null
                          : () => _handleDecline(context, invitation, provider),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red,
                        side: const BorderSide(color: Colors.red),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: const Text('Từ chối'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: provider.isActionInProgress
                          ? null
                          : () => _handleAccept(context, invitation, provider),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue[600],
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        elevation: 0,
                      ),
                      child: const Text('Chấp nhận'),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color color;
    String text;

    switch (status) {
      case 'accepted':
        color = Colors.green;
        text = 'Đã chấp nhận';
        break;
      case 'declined':
        color = Colors.red;
        text = 'Đã từ chối';
        break;
      default:
        color = Colors.orange;
        text = 'Đang chờ';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        text,
        style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold),
      ),
    );
  }

  Future<void> _handleAccept(BuildContext context, CandidateInvitationEntity invitation, HeadhuntingProvider provider) async {
    final success = await provider.acceptCandidateInvitation(invitation.id);
    if (!mounted) return;
    
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Bạn đã chấp nhận thư mời. Đơn ứng tuyển đã được tạo!'), backgroundColor: Colors.green),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(provider.candidateInvitationError ?? 'Có lỗi xảy ra'), backgroundColor: Colors.red),
      );
    }
  }

  Future<void> _handleDecline(BuildContext context, CandidateInvitationEntity invitation, HeadhuntingProvider provider) async {
    final success = await provider.declineCandidateInvitation(invitation.id);
    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Bạn đã từ chối thư mời.'), backgroundColor: Colors.orange),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(provider.candidateInvitationError ?? 'Có lỗi xảy ra'), backgroundColor: Colors.red),
      );
    }
  }
}
