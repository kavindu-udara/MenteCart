import '../../../../core/errors/exceptions.dart';
import '../data_sources/auth_remote_data_source.dart';

class AuthRepository {
  final AuthRemoteDataSource remoteDataSource;

  AuthRepository({required this.remoteDataSource});

  /// Signup with email and password
  Future<Map<String, dynamic>> signup({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
  }) async {
    try {
      final result = await remoteDataSource.signup(
        firstName: firstName,
        lastName: lastName,
        email: email,
        password: password,
      );
      return result;
    } on AppException {
      rethrow;
    }
  }

  /// Login with email and password
  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      final result = await remoteDataSource.login(
        email: email,
        password: password,
      );
      return result;
    } on AppException {
      rethrow;
    }
  }

  /// Get current authenticated user profile
  Future<Map<String, dynamic>> me() async {
    try {
      final result = await remoteDataSource.me();
      return result;
    } on AppException {
      rethrow;
    }
  }
}
