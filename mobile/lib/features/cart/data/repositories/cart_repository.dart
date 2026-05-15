import 'package:mobile/shared/services/api_client.dart';
import '../models/cart_model.dart';

class CartRepository {
  final ApiClient _apiClient;

  CartRepository({required ApiClient apiClient}) : _apiClient = apiClient;

  Future<CartModel> getCart() async {
    try {
      final response = await _apiClient.get('cart');
      return CartModel.fromJson(response['cart'] as Map<String, dynamic>? ?? {});
    } catch (e) {
      rethrow;
    }
  }

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

  Future<void> removeItem(String itemId) async {
    try {
      await _apiClient.delete('cart/items/$itemId');
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateItemQuantity(String itemId, int quantity) async {
    try {
      await _apiClient.patch('cart/items/$itemId', data: {'quantity': quantity});
    } catch (e) {
      rethrow;
    }
  }
}
