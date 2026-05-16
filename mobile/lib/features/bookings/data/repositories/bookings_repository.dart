import 'package:mente_cart/shared/services/api_client.dart';

import '../models/booking_model.dart';

class BookingsRepository {
  final ApiClient _apiClient;

  BookingsRepository({required ApiClient apiClient}) : _apiClient = apiClient;

  Future<List<BookingModel>> getBookings() async {
    final response = await _apiClient.get('bookings');
    final bookingsJson = (response['bookings'] as List?) ?? const [];

    return bookingsJson
        .whereType<Map>()
      .map((booking) => BookingModel.fromJson(Map<String, dynamic>.from(booking)))
        .toList();
  }

  Future<void> cancelBooking(String bookingId) async {
    await _apiClient.post('bookings/$bookingId/cancel', data: const {});
  }
}
