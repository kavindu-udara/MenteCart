import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../../core/errors/exceptions.dart';

class ApiClient {
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

    // Add error interceptor
    _dio.interceptors.add(_ErrorInterceptor());
    
    // Add cookie interceptor to automatically send cookies with every request
    _dio.interceptors.add(_CookieInterceptor());
  }

  /// POST request
  Future<Map<String, dynamic>> post(
    String endpoint, {
    required Map<String, dynamic> data,
  }) async {
    try {
      final response = await _dio.post(endpoint, data: data);
      return response.data is Map ? response.data : {};
    } on DioException catch (e) {
      _handleDioError(e);
      rethrow;
    }
  }

  /// GET request
  Future<Map<String, dynamic>> get(String endpoint) async {
    try {
      final response = await _dio.get(endpoint);
      return response.data is Map ? response.data : {};
    } on DioException catch (e) {
      _handleDioError(e);
      rethrow;
    }
  }

  /// Handle Dio errors and convert to AppException
  void _handleDioError(DioException error) {
    int statusCode = error.response?.statusCode ?? 500;
    String message = 'An error occurred';
    String? errorCode;

    if (error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.receiveTimeout ||
        error.type == DioExceptionType.sendTimeout) {
      statusCode = 408;
      message = 'Connection timeout. Please check your internet.';
      errorCode = 'TIMEOUT';
    } else if (error.type == DioExceptionType.unknown) {
      message = 'Network error. Please check your connection.';
      errorCode = 'NETWORK_ERROR';
    } else if (error.response != null) {
      final responseData = error.response!.data;
      if (responseData is Map) {
        message = responseData['message'] ?? 'Request failed';
        errorCode = responseData['errorCode'];
      }
    }

    throw AppException(
      statusCode: statusCode,
      message: message,
      errorCode: errorCode,
    );
  }
}

/// Error interceptor for Dio
class _ErrorInterceptor extends Interceptor {
  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    // Check if response contains error
    if (response.statusCode != null && response.statusCode! >= 400) {
      final data = response.data;
      if (data is Map) {
        throw AppException(
          statusCode: response.statusCode!,
          message: data['message'] ?? 'Request failed',
          errorCode: data['errorCode'],
        );
      } else {
        throw AppException(
          statusCode: response.statusCode!,
          message: 'Request failed',
        );
      }
    }
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    handler.next(err);
  }
}

/// Cookie interceptor to automatically handle HTTP-only cookies
class _CookieInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    // Dio automatically handles cookies when sending requests
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    // Dio automatically handles Set-Cookie headers from responses
    handler.next(response);
  }
}
