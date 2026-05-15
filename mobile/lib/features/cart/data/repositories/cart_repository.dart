import 'package:mobile/shared/services/api_client.dart';

class CartRepository {
  final ApiClient _apiClient;

  CartRepository({required ApiClient apiClient}) : _apiClient = apiClient;

  Future<Map<String, dynamic>> addItem({
    required String serviceId,
    required String selectedDate,
    required String timeSlotStart,
    required String timeSlotEnd,
  }) async {
    final payload = {
      'serviceId': serviceId,
      'selectedDate': selectedDate,
      'timeSlotStart': timeSlotStart,
      'timeSlotEnd': timeSlotEnd,
    };

    try {
      final response = await _apiClient.post('cart/items', data: payload);
      return response;
    } catch (e) {
      rethrow;
    }
  }
}
