// Sirve de contrato (puerto) para que la UI dependa de abstracciones y no de implementaciones directas

abstract class AuthRepository {
  Future<void> login({required String username, required String password});
  Future<void> register({required String username, required String password});
  Future<bool> checkAuthStatus();
  Future<void> logout();
}