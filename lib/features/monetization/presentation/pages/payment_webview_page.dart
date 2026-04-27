import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../providers/monetization_provider.dart';
import 'payment_result_page.dart';

class PaymentWebViewPage extends StatefulWidget {
  final String initialUrl;

  const PaymentWebViewPage({super.key, required this.initialUrl});

  @override
  State<PaymentWebViewPage> createState() => _PaymentWebViewPageState();
}

class _PaymentWebViewPageState extends State<PaymentWebViewPage> {
  late final WebViewController _controller;
  bool _isVerifying = false;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onNavigationRequest: (NavigationRequest request) {
            // Trường hợp 1: BE redirect về FRONTEND_URL (thường là Web)
            if (request.url.contains('/payment/result')) {
              _handlePaymentResult(request.url);
              return NavigationDecision.prevent;
            }
            
            // Trường hợp 2: WebView bị kẹt ở URL của BE (localhost/10.0.2.2) do lỗi cấu hình hoặc không redirect
            if (request.url.contains('/api/payments/vnpay/return')) {
              _handleInternalReturnUrl(request.url);
              return NavigationDecision.prevent;
            }
            
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.initialUrl));
  }

  void _handleInternalReturnUrl(String url) async {
    if (_isVerifying) return;

    setState(() {
      _isVerifying = true;
    });

    final uri = Uri.parse(url);
    final queryParams = uri.queryParameters;

    final provider = context.read<MonetizationProvider>();
    // Gọi API verify thông qua repository (ApiClient sẽ tự dùng 10.0.2.2)
    final result = await provider.repository.verifyVnpayPayment(queryParams);

    if (mounted) {
      result.fold(
        (failure) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => PaymentResultPage(
                isSuccess: false,
                message: failure.message,
              ),
            ),
          );
        },
        (data) {
          provider.fetchSubscriptionStatus();
          provider.fetchCreditBalance();
          
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => PaymentResultPage(
                isSuccess: data['status'] == 'success',
                message: data['message'] ?? 'Thanh toán thành công',
              ),
            ),
          );
        },
      );
    }
  }

  void _handlePaymentResult(String url) {
    if (_isVerifying) return;

    setState(() {
      _isVerifying = true;
    });

    final uri = Uri.parse(url);
    final isSuccess = uri.queryParameters['success'] == 'true';
    final message = uri.queryParameters['message'] ?? (isSuccess ? 'Thanh toán thành công' : 'Thanh toán thất bại');

    final provider = context.read<MonetizationProvider>();
    
    // Refresh data if success
    if (isSuccess) {
      provider.fetchSubscriptionStatus();
      provider.fetchCreditBalance();
    }
          
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => PaymentResultPage(
          isSuccess: isSuccess,
          message: message,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Thanh toán VNPay'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (_isVerifying)
            Container(
              color: Colors.black.withOpacity(0.3),
              child: const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text(
                      'Đang xác thực thanh toán...',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
