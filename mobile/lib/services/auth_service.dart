import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:convert';

class AuthService {
  static String? _getBaseUrl() {
    return dotenv.env['API_BASE_URL'];
  }

  static Future<Map<String, dynamic>> signup({
    required String email,
    required String password,
  }) async {
    try {
      final baseUrl = _getBaseUrl();
      
      if (baseUrl == null) {
        return {
          'success': false,
          'message': 'API base URL not configured',
        };
      }

      final url = Uri.parse('${baseUrl}auth/signup');

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return {
          'success': true,
          'message': responseData['message'] ?? 'Account created successfully',
          'data': responseData,
        };
      } else {
        return {
          'success': false,
          'message': responseData['message'] ?? 'Signup failed',
          'statusCode': response.statusCode,
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Error: ${e.toString()}',
      };
    }
  }
}
