import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repositories/auth_repository.dart';
import '../../../../core/errors/exceptions.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository repository;

  AuthBloc({required this.repository}) : super(const AuthState.initial()) {
    on<SignupRequested>(_onSignupRequested);
    on<LoginRequested>(_onLoginRequested);
  }

  /// Handle signup event
  Future<void> _onSignupRequested(
    SignupRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthState.loading());
    
    try {
      final result = await repository.signup(
        email: event.email,
        password: event.password,
      );
      
      emit(AuthState.signupSuccess(message: result['message'] ?? 'Account created'));
    } on AppException catch (e) {
      emit(AuthState.error(message: e.message, errorCode: e.errorCode));
    } catch (e) {
      emit(AuthState.error(message: e.toString()));
    }
  }

  /// Handle login event
  Future<void> _onLoginRequested(
    LoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthState.loading());
    
    try {
      final result = await repository.login(
        email: event.email,
        password: event.password,
      );
      
      // Login successful - emit authenticated state
      // JWT token is now stored in HTTP-only cookie and will be sent with every request
      emit(AuthState.authenticated(
        message: result['message'] ?? 'Login successful',
      ));
    } on AppException catch (e) {
      emit(AuthState.error(message: e.message, errorCode: e.errorCode));
    } catch (e) {
      emit(AuthState.error(message: e.toString()));
    }
  }
}
