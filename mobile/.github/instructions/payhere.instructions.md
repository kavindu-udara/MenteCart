## Checkout Bloc: Handle PayHere Response
```dart
// features/checkout/presentation/bloc/checkout_bloc.dart
class CheckoutBloc extends Bloc<CheckoutEvent, CheckoutState> {
  Future<void> _onConfirmBooking(ConfirmBooking event, Emitter<CheckoutState> emit) async {
    emit(CheckoutLoading());
    
    try {
      final result = await _repository.checkout(
        paymentMethod: event.paymentMethod,
      );
      
      if (event.paymentMethod == PaymentMethod.payhere) {
        // 🔄 Navigate to PayHere WebView
        emit(CheckoutPayHereRedirect(
          booking: result,
          paymentUrl: result.paymentInstructions!.url,
          params: result.paymentInstructions!.params,
        ));
      } else {
        // ✅ Cash/pay-on-arrival: immediate success
        emit(CheckoutSuccess(booking: result));
      }
    } catch (e) {
      emit(CheckoutError(message: _mapError(e)));
    }
  }
}
```

## PayHere WebView Screen
```dart
// features/checkout/presentation/pages/payhere_webview_page.dart
class PayHereWebViewPage extends StatefulWidget {
  final String paymentUrl;
  final Map<String, String> params;
  final String bookingId;
  
  const PayHereWebViewPage({
    required this.paymentUrl,
    required this.params,
    required this.bookingId,
  });
  
  @override
  State<PayHereWebViewPage> createState() => _PayHereWebViewPageState();
}

class _PayHereWebViewPageState extends State<PayHereWebViewPage> {
  late final WebViewController _controller;
  bool _isLoading = true;
  
  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (_) => setState(() => _isLoading = false),
          onUrlChange: (url) => _handleRedirect(url),
        ),
      )
      ..loadRequest(
        Uri.parse(widget.paymentUrl),
        method: 'POST',
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: widget.params,
      );
  }
  
  void _handleRedirect(Uri url) {
    // PayHere redirects to return_url or cancel_url
    if (url.path.contains('/payment/return')) {
      // 🎉 Payment completed → poll for final status
      _startPollingBookingStatus();
    } else if (url.path.contains('/payment/cancel')) {
      // ❌ User cancelled → show message
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Payment cancelled')),
      );
    }
  }
  
  void _startPollingBookingStatus() {
    // Poll GET /bookings/:id every 3 seconds until status != 'pending'
    Timer.periodic(Duration(seconds: 3), (timer) async {
      final booking = await context.read<BookingsBloc>().fetchBooking(widget.bookingId);
      
      if (booking?.status != BookingStatus.pending) {
        timer.cancel();
        if (booking?.status == BookingStatus.confirmed) {
          Navigator.popUntil(context, (route) => route.isFirst);
          context.read<BookingsBloc>().add(LoadBookings());
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Booking confirmed! 🎉')),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Payment failed. Please try again.')),
          );
        }
      }
    });
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Secure Payment')),
      body: _isLoading 
        ? Center(child: CircularProgressIndicator())
        : WebViewWidget(controller: _controller),
    );
  }
}
```

## API Client: Checkout Endpoint
```dart
// shared/services/api_client.dart
Future<Booking> checkout({required PaymentMethod paymentMethod}) async {
  final response = await _dio.post(
    '/bookings/checkout',
    data: {'paymentMethod': paymentMethod.name},
  );
  
  return Booking.fromJson(response.data);
}
```
