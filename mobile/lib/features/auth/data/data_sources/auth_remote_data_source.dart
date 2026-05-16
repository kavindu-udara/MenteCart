import '../../../../shared/services/api_client.dart';
import '../../../../core/errors/exceptions.dart';

class AuthRemoteDataSource {
  final ApiClient apiClient;

  AuthRemoteDataSource({required this.apiClient});

  /// Signup - POST /auth/signup
  Future<Map<String, dynamic>> signup({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
  }) async {
    try {
      final response = await apiClient.post(
        'auth/signup',
        data: {
          'firstName': firstName,
          'lastName': lastName,
          'email': email,
          'password': password,
        },
      );
      return response;
    } on AppException {
      rethrow;
    }
  }

  /// Login - POST /auth/login
  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await apiClient.post(
        'auth/login',
        data: {
          'email': email,
          'password': password,
        },
      );
      return response;
    } on AppException {
      rethrow;
    }
  }

  /// Me - GET /auth/me
  Future<Map<String, dynamic>> me() async {
    try {
      final response = await apiClient.get('auth/me');
      return response;
    } on AppException {
      rethrow;
    }
  }
}
