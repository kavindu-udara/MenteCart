part of 'auth_bloc.dart';

sealed class AuthState {
  const AuthState();

  /// Initial state
  const factory AuthState.initial() = AuthInitial;

  /// Loading state
  const factory AuthState.loading() = AuthLoading;

  /// User authenticated state (logged in)
  const factory AuthState.authenticated({required String message}) =
      AuthAuthenticated;

  /// Signup success state
  const factory AuthState.signupSuccess({required String message}) =
      AuthSignupSuccess;

  /// Error state
  const factory AuthState.error({
    required String message,
    String? errorCode,
  }) = AuthError;
}

class AuthInitial extends AuthState {
  const AuthInitial();
}

class AuthLoading extends AuthState {
  const AuthLoading();
}

class AuthAuthenticated extends AuthState {
  final String message;

  const AuthAuthenticated({required this.message});
}

class AuthSignupSuccess extends AuthState {
  final String message;

  const AuthSignupSuccess({required this.message});
}

class AuthError extends AuthState {
  final String message;
  final String? errorCode;

  const AuthError({required this.message, this.errorCode});
}
