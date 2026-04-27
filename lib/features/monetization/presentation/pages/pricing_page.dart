import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/monetization_provider.dart';
import '../../domain/entities/subscription_package_entity.dart';
import 'payment_webview_page.dart';

class PricingPage extends StatefulWidget {
  const PricingPage({super.key});

  @override
  State<PricingPage> createState() => _PricingPageState();
}

class _PricingPageState extends State<PricingPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MonetizationProvider>().fetchPackages();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currencyFormat = NumberFormat.currency(locale: 'vi_VN', symbol: 'đ');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Nâng cấp tài khoản', style: TextStyle(fontWeight: FontWeight.bold)),
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
                    onPressed: () => provider.fetchPackages(),
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
                const Text(
                  'Chọn gói cước phù hợp với nhu cầu của bạn',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                ...provider.packages.map((package) => _buildPackageCard(context, package, currencyFormat)),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildPackageCard(
    BuildContext context,
    SubscriptionPackageEntity package,
    NumberFormat currencyFormat,
  ) {
    final theme = Theme.of(context);
    final isVip = package.isVip;

    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isVip ? theme.colorScheme.primary : Colors.grey[200]!,
          width: isVip ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: isVip
                ? theme.colorScheme.primary.withOpacity(0.1)
                : Colors.black.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        children: [
          if (isVip)
            Positioned(
              top: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary,
                  borderRadius: const BorderRadius.only(
                    topRight: Radius.circular(18),
                    bottomLeft: Radius.circular(20),
                  ),
                ),
                child: const Text(
                  'PHỔ BIẾN NHẤT',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      isVip ? Icons.workspace_premium : Icons.person_outline,
                      color: isVip ? theme.colorScheme.primary : Colors.grey,
                      size: 32,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      package.displayName,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      package.price == 0 ? 'Miễn phí' : currencyFormat.format(package.price),
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: isVip ? theme.colorScheme.primary : Colors.black,
                      ),
                    ),
                    if (package.price > 0)
                      const Text(
                        ' / tháng',
                        style: TextStyle(color: Colors.grey, fontSize: 16),
                      ),
                  ],
                ),
                const Divider(height: 32),
                _buildFeatureRow(Icons.check_circle, 'Đăng tối đa ${package.maxActiveJobs} tin'),
                _buildFeatureRow(Icons.check_circle, 'Thời hạn tin: ${package.jobDurationDays} ngày'),
                _buildFeatureRow(
                  package.maxProfileViewsPerJob == -1 ? Icons.all_inclusive : Icons.check_circle,
                  package.maxProfileViewsPerJob == -1 
                    ? 'Xem hồ sơ không giới hạn' 
                    : 'Xem ${package.maxProfileViewsPerJob} hồ sơ / tin',
                ),
                if (package.canHideSalary)
                  _buildFeatureRow(Icons.check_circle, 'Tính năng ẩn mức lương'),
                if (package.canRequireCv)
                  _buildFeatureRow(Icons.check_circle, 'Yêu cầu ứng viên nộp CV'),
                if (package.hasVipBadge)
                  _buildFeatureRow(Icons.check_circle, 'Huy hiệu VIP trên trang công ty'),
                if (package.freeAiScoring)
                  _buildFeatureRow(Icons.check_circle, 'AI chấm điểm hồ sơ tự động'),
                if (package.monthlyFreeProceeds > 0)
                  _buildFeatureRow(Icons.check_circle, 'Miễn phí ${package.monthlyFreeProceeds} lượt duyệt UV/tháng'),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: package.price == 0 
                      ? null 
                      : () => _handlePayment(context, package),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isVip ? theme.colorScheme.primary : Colors.grey[100],
                      foregroundColor: isVip ? Colors.white : Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      package.price == 0 ? 'Gói hiện tại' : 'Nâng cấp ngay',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, color: Colors.green, size: 20),
          const SizedBox(width: 12),
          Expanded(child: Text(text, style: const TextStyle(fontSize: 15))),
        ],
      ),
    );
  }

  void _handlePayment(BuildContext context, SubscriptionPackageEntity package) async {
    final provider = context.read<MonetizationProvider>();
    final paymentUrl = await provider.createVipOrder();
    
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
