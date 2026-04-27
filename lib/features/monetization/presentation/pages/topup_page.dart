import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/monetization_provider.dart';
import '../../domain/entities/topup_pack_entity.dart';
import 'payment_webview_page.dart';

class TopupPage extends StatefulWidget {
  const TopupPage({super.key});

  @override
  State<TopupPage> createState() => _TopupPageState();
}

class _TopupPageState extends State<TopupPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MonetizationProvider>().fetchTopupPacks();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currencyFormat = NumberFormat.currency(locale: 'vi_VN', symbol: 'đ');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Nạp Credit', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: Consumer<MonetizationProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.errorMessage != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(provider.errorMessage!),
                  ElevatedButton(
                    onPressed: () => provider.fetchTopupPacks(),
                    child: const Text('Thử lại'),
                  ),
                ],
              ),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildBalanceCard(context, provider.creditBalance),
                const SizedBox(height: 24),
                const Text(
                  'Chọn gói nạp phù hợp',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.85,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                  ),
                  itemCount: provider.topupPacks.length,
                  itemBuilder: (context, index) {
                    final pack = provider.topupPacks[index];
                    return _buildPackCard(context, pack, currencyFormat);
                  },
                ),
                const SizedBox(height: 24),
                _buildInfoSection(context),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildBalanceCard(BuildContext context, int balance) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [theme.colorScheme.primary, theme.colorScheme.primary.withOpacity(0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.primary.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Số dư hiện tại',
            style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 16),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.toll, color: Colors.amber, size: 32),
              const SizedBox(width: 12),
              Text(
                '$balance Credits',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPackCard(BuildContext context, TopupPackEntity pack, NumberFormat currencyFormat) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: () => _handlePayment(context, pack),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey[200]!),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.toll, color: Colors.amber, size: 40),
            const SizedBox(height: 12),
            Text(
              '${pack.creditBase} Credits',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            if (pack.bonus > 0)
              Text(
                '+${pack.bonus} Bonus',
                style: const TextStyle(color: Colors.green, fontWeight: FontWeight.w500),
              ),
            const SizedBox(height: 12),
            Text(
              currencyFormat.format(pack.priceVnd),
              style: TextStyle(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.info_outline, size: 20, color: Colors.grey),
              SizedBox(width: 8),
              Text(
                'Lưu ý về Credits',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          SizedBox(height: 12),
          Text(
            '• Credits dùng để trả phí xử lý hồ sơ ứng viên.\n'
            '• Mua các gói hỗ trợ như Đẩy tin, Gia hạn tin.\n'
            '• Credits không có thời hạn sử dụng.',
            style: TextStyle(color: Colors.black87, fontSize: 14, height: 1.5),
          ),
        ],
      ),
    );
  }

  void _handlePayment(BuildContext context, TopupPackEntity pack) async {
    final provider = context.read<MonetizationProvider>();
    final paymentUrl = await provider.createCreditOrder(pack.id);
    
    if (paymentUrl != null && mounted) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => PaymentWebViewPage(initialUrl: paymentUrl),
        ),
      );
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Không thể tạo đơn hàng. Vui lòng thử lại sau.')),
      );
    }
  }
}
