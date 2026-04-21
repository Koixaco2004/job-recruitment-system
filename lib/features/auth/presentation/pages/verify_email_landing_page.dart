import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

class VerifyEmailLandingPage extends StatefulWidget {
  final String? token;

  const VerifyEmailLandingPage({super.key, this.token});

  @override
  State<VerifyEmailLandingPage> createState() => _VerifyEmailLandingPageState();
}

class _VerifyEmailLandingPageState extends State<VerifyEmailLandingPage> {
  bool _isProcessing = false;
  String? _statusMessage;
  bool _isSuccess = false;

  @override
  void initState() {
    super.initState();
    if (widget.token != null) {
      _verify(widget.token!);
    } else {
      _statusMessage = 'Không tìm thấy mã xác thực.';
    }
  }

  Future<void> _verify(String token) async {
    setState(() {
      _isProcessing = true;
      _statusMessage = 'Đang xác thực tài khoản...';
    });

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final success = await authProvider.verifyEmail(token);

    if (mounted) {
      setState(() {
        _isProcessing = false;
        _isSuccess = success;
        _statusMessage = success 
            ? 'Xác thực tài khoản thành công! Bạn có thể quay lại trang chủ.' 
            : (authProvider.errorMessage ?? 'Xác thực thất bại. Mã có thể đã hết hạn.');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Xác thực tài khoản'),
        automaticallyImplyLeading: false,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (_isProcessing)
                const CircularProgressIndicator()
              else
                Icon(
                  _isSuccess ? Icons.check_circle_outline : Icons.error_outline,
                  size: 100,
                  color: _isSuccess ? Colors.green : Colors.red,
                ),
              const SizedBox(height: 32),
              Text(
                _statusMessage ?? '',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 18),
              ),
              const SizedBox(height: 48),
              if (!_isProcessing)
                ElevatedButton(
                  onPressed: () {
                    // Quay về trang chủ (xóa hết stack)
                    Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
                  },
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 50),
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Quay về Trang chủ'),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
