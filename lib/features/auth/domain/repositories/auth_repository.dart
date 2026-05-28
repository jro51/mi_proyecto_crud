// Sirve de contrato (puerto) para que la UI dependa de abstracciones y no de implementaciones directas

abstract class AuthRepository {
  Future<Map<String, dynamic>> login({required String username, required String password});
  Future<Map<String, dynamic>> register({required String username, required String password});
  Future<bool> checkAuthStatus();
  Future<void> logout();
  Future<String?> getAuthenticatedUsername();
  Future<String?> getAuthenticatedUserId();
}