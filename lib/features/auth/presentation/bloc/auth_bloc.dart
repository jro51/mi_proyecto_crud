import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/auth_repository.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository _authRepository;

  AuthBloc({required AuthRepository authRepository})
      : _authRepository = authRepository,
        super(AuthInitial()) {
    
    // Mapeo de Eventos a Estados usando la sintaxis moderna de Bloc 8.x
    on<AuthCheckRequested>(_onAuthCheckRequested);
    on<LoginSubmitted>(_onLoginSubmitted);
    on<RegisterSubmitted>(_onRegisterSubmitted);
    on<LogoutRequested>(_onLogoutRequested);
  }

  Future<void> _onAuthCheckRequested(AuthCheckRequested event, Emitter<AuthState> emit) async {
    final isAuthenticated = await _authRepository.checkAuthStatus();
    if (isAuthenticated) {
      emit(Authenticated());
    } else {
      emit(Unauthenticated());
    }
  }

  Future<void> _onLoginSubmitted(LoginSubmitted event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      await _authRepository.login(username: event.username, password: event.password);
      emit(Authenticated());
    } catch (e) {
      emit(AuthFailure(errorMessage: e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> _onRegisterSubmitted(RegisterSubmitted event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      await _authRepository.register(username: event.username, password: event.password);
      emit(Authenticated());
    } catch (e) {
      emit(AuthFailure(errorMessage: e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> _onLogoutRequested(LogoutRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    await _authRepository.logout();
    emit(Unauthenticated());
  }
}