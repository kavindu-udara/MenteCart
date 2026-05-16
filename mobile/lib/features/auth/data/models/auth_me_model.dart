class AuthMeModel {
  final String firstName;
  final String lastName;
  final String email;
  final String role;
  final String message;

  const AuthMeModel({
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.role,
    required this.message,
  });

  factory AuthMeModel.fromJson(Map<String, dynamic> json) {
    final user = json['user'] as Map<String, dynamic>? ?? const {};

    return AuthMeModel(
      firstName: user['firstName']?.toString() ?? '',
      lastName: user['lastName']?.toString() ?? '',
      email: user['email']?.toString() ?? '',
      role: user['role']?.toString() ?? '',
      message: json['message']?.toString() ?? 'User retrieved successfully',
    );
  }

  String get fullName {
    final parts = [firstName, lastName].where((part) => part.trim().isNotEmpty).toList();
    return parts.isEmpty ? 'Profile' : parts.join(' ');
  }
}
