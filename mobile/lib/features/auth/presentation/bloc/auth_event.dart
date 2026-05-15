part of 'auth_bloc.dart';

sealed class AuthEvent {
  const AuthEvent();
}

/// Signup event
class SignupRequested extends AuthEvent {
  final String email;
  final String password;

  const SignupRequested({
    required this.email,
    required this.password,
  });
}

/// Login event
class LoginRequested extends AuthEvent {
  final String email;
  final String password;

  const LoginRequested({
    required this.email,
    required this.password,
  });
}
