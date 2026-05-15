part of 'auth_bloc.dart';

sealed class AuthState {
  const AuthState();

  /// Initial state
  const factory AuthState.initial() = AuthInitial;

  /// Loading state
  const factory AuthState.loading() = AuthLoading;

  /// Signup success state
  const factory AuthState.signupSuccess({required String message}) =
      AuthSignupSuccess;

  /// Login success state
  const factory AuthState.loginSuccess({
    required String message,
    String? token,
  }) = AuthLoginSuccess;

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

class AuthSignupSuccess extends AuthState {
  final String message;

  const AuthSignupSuccess({required this.message});
}

class AuthLoginSuccess extends AuthState {
  final String message;
  final String? token;

  const AuthLoginSuccess({required this.message, this.token});
}

class AuthError extends AuthState {
  final String message;
  final String? errorCode;

  const AuthError({required this.message, this.errorCode});
}
