import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_typography.dart';
import '../../core/models/order.dart';

/// Screen: payment_webview_screen
/// Embedded secure Flutterwave payment webview redirect
class PaymentWebViewScreen extends StatefulWidget {
  final String paymentUrl;
  final CommissionOrder order;

  const PaymentWebViewScreen({
    super.key,
    required this.paymentUrl,
    required this.order,
  });

  @override
  State<PaymentWebViewScreen> createState() => _PaymentWebViewScreenState();
}

class _PaymentWebViewScreenState extends State<PaymentWebViewScreen> {
  late final WebViewController _controller;
  bool _isLoading = true;
  int _progress = 0;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(AppColors.background)
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            if (mounted) {
              setState(() {
                _progress = progress;
                _isLoading = progress < 100;
              });
            }
          },
          onPageStarted: (String url) {
            if (mounted) setState(() => _isLoading = true);
          },
          onPageFinished: (String url) {
            if (mounted) setState(() => _isLoading = false);
          },
          onWebResourceError: (WebResourceError error) {
            debugPrint('Payment WebView error: ${error.description}');
          },
          onNavigationRequest: (NavigationRequest request) {
            final url = request.url.toLowerCase();
            // Check for payment callback / completion triggers
            if (url.contains('status=successful') ||
                url.contains('status=completed') ||
                url.contains('tx_ref') ||
                url.contains('payment-success') ||
                url.contains('order-confirmation')) {
              _navigateToConfirmation();
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.paymentUrl));
  }

  void _navigateToConfirmation() {
    if (mounted) {
      context.go('/order-confirmation', extra: widget.order);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.close, size: 22),
          onPressed: () {
            // Confirm if user wants to exit
            showDialog(
              context: context,
              builder: (ctx) => AlertDialog(
                backgroundColor: AppColors.surface,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                title: Text(
                  'Exit Payment?',
                  style: AppTypography.headlineSM(color: AppColors.textPrimary),
                ),
                content: Text(
                  'Your order has been placed. You can view details and complete payment anytime from the Orders page.',
                  style: AppTypography.bodySM(color: AppColors.textSecondary),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(ctx),
                    child: Text(
                      'CONTINUE PAYMENT',
                      style: AppTypography.labelSM(color: AppColors.primaryGold),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.pop(ctx);
                      _navigateToConfirmation();
                    },
                    child: Text(
                      'EXIT',
                      style: AppTypography.labelSM(color: AppColors.error),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
        title: Text(
          'SECURE PAYMENT',
          style: AppTypography.labelLG(color: AppColors.textPrimary).copyWith(letterSpacing: 2),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, size: 20),
            onPressed: () => _controller.reload(),
          ),
        ],
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (_isLoading)
            LinearProgressIndicator(
              value: _progress > 0 ? _progress / 100.0 : null,
              backgroundColor: AppColors.surface,
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primaryGold),
            ),
        ],
      ),
    );
  }
}
