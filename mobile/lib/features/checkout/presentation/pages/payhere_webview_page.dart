import 'dart:async';

import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../../../shared/services/api_client.dart';

class PayHereWebViewPage extends StatefulWidget {
  final String paymentUrl;
  final Map<String, String> params;
  final String bookingId;
  final VoidCallback onBookingSettled;

  const PayHereWebViewPage({
    required this.paymentUrl,
    required this.params,
    required this.bookingId,
    required this.onBookingSettled,
    super.key,
  });

  @override
  State<PayHereWebViewPage> createState() => _PayHereWebViewPageState();
}

class _PayHereWebViewPageState extends State<PayHereWebViewPage> {
  late final WebViewController _controller;
  bool _isLoading = true;
  Timer? _pollTimer;
  final _apiClient = ApiClient();

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (_) => setState(() => _isLoading = false),
          onNavigationRequest: (request) {
            _handleRedirect(Uri.parse(request.url));
            return NavigationDecision.navigate;
          },
        ),
      );

    // Build a form post by injecting a small HTML that posts to the paymentUrl
    final html = '''
<html>
  <body onload="document.forms[0].submit()">
    <form method="post" action="${widget.paymentUrl}">
      ${widget.params.entries.map((e) => '<input type="hidden" name="${e.key}" value="${e.value}">').join()} 
    </form>
  </body>
</html>
''';

    _controller.loadHtmlString(html);
  }

  void _handleRedirect(Uri url) {
    final path = url.path;
    if (path.contains('/payment/return')) {
      _startPollingBookingStatus();
    } else if (path.contains('/payment/cancel')) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Payment cancelled')),
      );
    }
  }

  void _startPollingBookingStatus() {
    // Show processing message
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => const AlertDialog(
        content: SizedBox(
          height: 80,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 12),
              Text('Payment processing...'),
            ],
          ),
        ),
      ),
    );

    _pollTimer = Timer.periodic(const Duration(seconds: 3), (timer) async {
      try {
        final res = await _apiClient.get('bookings/${widget.bookingId}');
        final booking = res['booking'] as Map<String, dynamic>?;
        final status = booking?['status'] as String?;

        if (status != null && status != 'pending') {
          timer.cancel();
          widget.onBookingSettled();
          Navigator.of(context).popUntil((route) => route.isFirst);

          if (status == 'confirmed') {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Booking confirmed! 🎉')),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Payment failed. Please try again.')),
            );
          }
        }
      } catch (e) {
        // ignore and continue polling
      }
    });
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Secure Payment')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : WebViewWidget(controller: _controller),
    );
  }
}
