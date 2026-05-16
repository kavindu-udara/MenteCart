import 'package:mente_cart/shared/services/api_client.dart';
import '../models/service_model.dart';

class ServicesRepository {
  final ApiClient _apiClient;

  ServicesRepository({required ApiClient apiClient}) : _apiClient = apiClient;

  Future<ServicesResponse> getServices() async {
    try {
      final response = await _apiClient.get('services');
      return ServicesResponse.fromJson(response);
    } catch (e) {
      rethrow;
    }
  }

  Future<ServiceModel> getServiceById(String serviceId) async {
    try {
      final response = await _apiClient.get('services/$serviceId');
      return ServiceDetailsResponse.fromJson(response).service;
    } catch (e) {
      rethrow;
    }
  }

  Future<ServiceModel> getServiceSlots(String serviceId, String date) async {
    try {
      final response = await _apiClient.get('services/$serviceId?date=$date');
      return ServiceDetailsResponse.fromJson(response).service;
    } catch (e) {
      rethrow;
    }
  }
}
