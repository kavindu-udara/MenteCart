import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import '../../core/errors/exceptions.dart';

class ApiClient {
  static final CookieJar _cookieJar = CookieJar();
  late final Dio _dio;

  ApiClient() {
    final baseUrl = dotenv.env['API_BASE_URL'];
    
    _dio = Dio(
      BaseOptions(
        baseUrl: baseUrl ?? 'http://192.168.38.54:3000/api/',
        contentType: 'application/json',
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
        validateStatus: (status) => true, // Don't throw on any status
      ),
    );

    // Add a shared CookieManager so the HTTP-only JWT cookie is reused across
    // all ApiClient instances created in different screens/features.
    _dio.interceptors.add(CookieManager(_cookieJar));
  }

  /// POST request
  Future<Map<String, dynamic>> post(
    String endpoint, {
    required Map<String, dynamic> data,
  }) async {
    try {
      final response = await _dio.post(endpoint, data: data);
      return _unwrapResponse(response);
    } on DioException catch (e) {
      _handleDioError(e);
    }
  }

  /// GET request
  Future<Map<String, dynamic>> get(String endpoint) async {
    try {
      final response = await _dio.get(endpoint);
      return _unwrapResponse(response);
    } on DioException catch (e) {
      _handleDioError(e);
    }
  }

  /// DELETE request
  Future<Map<String, dynamic>> delete(String endpoint) async {
    try {
      final response = await _dio.delete(endpoint);
      return _unwrapResponse(response);
    } on DioException catch (e) {
      _handleDioError(e);
    }
  }

  /// PATCH request
  Future<Map<String, dynamic>> patch(String endpoint, {Map<String, dynamic>? data}) async {
    try {
      final response = await _dio.patch(endpoint, data: data);
      return _unwrapResponse(response);
    } on DioException catch (e) {
      _handleDioError(e);
    }
  }

  Map<String, dynamic> _unwrapResponse(Response response) {
    final responseData = response.data;

    if (response.statusCode != null && response.statusCode! >= 400) {
      if (responseData is Map) {
        throw AppException(
          statusCode: response.statusCode!,
          message: responseData['message']?.toString() ?? 'Request failed',
          errorCode: responseData['errorCode']?.toString(),
        );
      }

      throw AppException(
        statusCode: response.statusCode!,
        message: 'Request failed',
      );
    }

    return responseData is Map<String, dynamic>
        ? responseData
        : responseData is Map
            ? responseData.map((key, value) => MapEntry(key.toString(), value))
            : <String, dynamic>{};
  }

  /// Handle Dio errors and convert to AppException
  Never _handleDioError(DioException error) {
    int statusCode = error.response?.statusCode ?? 500;
    String message = 'An error occurred';
    String? errorCode;

    if (error.response != null) {
      final responseData = error.response!.data;
      if (responseData is Map) {
        message = responseData['message']?.toString() ?? 'Request failed';
        errorCode = responseData['errorCode']?.toString();
        statusCode = error.response!.statusCode ?? statusCode;
      }
    } else if (error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.receiveTimeout ||
        error.type == DioExceptionType.sendTimeout) {
      statusCode = 408;
      message = 'Connection timeout. Please check your internet.';
      errorCode = 'TIMEOUT';
    } else if (error.type == DioExceptionType.unknown) {
      message = 'Network error. Please check your connection.';
      errorCode = 'NETWORK_ERROR';
    }

    throw AppException(
      statusCode: statusCode,
      message: message,
      errorCode: errorCode,
    );
  }
}

// CookieManager from dio_cookie_manager is used instead of a custom cookie interceptor.
