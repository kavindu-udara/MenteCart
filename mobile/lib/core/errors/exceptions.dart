/// Application-wide exception class
class AppException implements Exception {
  final int statusCode;
  final String message;
  final String? errorCode;

  const AppException({
    required this.statusCode,
    required this.message,
    this.errorCode,
  });

  @override
  String toString() => message;
}
