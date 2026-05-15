class AuthUser {
  final String? id;
  final String email;
  final String? name;

  const AuthUser({
    this.id,
    required this.email,
    this.name,
  });
}
