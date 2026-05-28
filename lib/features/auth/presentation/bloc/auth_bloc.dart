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
      final username = await _authRepository.getAuthenticatedUsername() ?? 'Usuario';
      
      // 🌟 Extraemos el ID numérico guardado (si tu repo devuelve String, conviértelo a int)
      final userIdStr = await _authRepository.getAuthenticatedUserId() ?? '0';
      final userId = int.tryParse(userIdStr) ?? 0;
      
      // ✅ Enviamos nombre e ID al estado
      emit(Authenticated(username: username, userId: userId)); 
    } else {
      emit(Unauthenticated());
    }
  }

  Future<void> _onLoginSubmitted(LoginSubmitted event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      // 🌟 Obtenemos los datos devueltos directamente del inicio de sesión
      final authData = await _authRepository.login(username: event.username, password: event.password);
      
      final username = authData['username'] as String;
      final userId = authData['userId'] as int;
      
      // ✅ Emitimos el estado con los datos en mano sin tocar el storage
      emit(Authenticated(username: username, userId: userId)); 
    } catch (e, stackTrace) {
      print("🚨 ERROR EN AUTH_BLOC LOGIN: $e");
      print("📌 STACKTRACE: $stackTrace");
      emit(AuthFailure(errorMessage: e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> _onRegisterSubmitted(RegisterSubmitted event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      // 🌟 Obtenemos los datos devueltos directamente del registro
      final authData = await _authRepository.register(username: event.username, password: event.password);
      
      final username = authData['username'] as String;
      final userId = authData['userId'] as int;
      
      // ✅ Emitimos el estado sin congelamientos
      emit(Authenticated(username: username, userId: userId)); 
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