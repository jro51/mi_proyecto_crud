import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class StorageService {
  // FlutterSecureStorage en lugar de SharedPreferences porque SharedPreferences
  // guarda datos en texto plano (un peligro para tokens), mientras que Secure Storage los cifra usando el hardware del celular.
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  static const String _tokenKey = 'jwt_token';
  static const String _userIdKey = 'user_id';

  // Guardar datos al iniciar sesión o registrarse
  Future<void> saveAuthData({required String token, required int userId}) async {
    await _storage.write(key: _tokenKey, value: token);
    await _storage.write(key: _userIdKey, value: userId.toString());
  }

  // Leer el Token para las cabeceras HTTP
  Future<String?> getToken() async {
    return await _storage.read(key: _tokenKey);
  }

  // Leer el ID del usuario para saber de quién son las copas
  Future<String?> getUserId() async {
    return await _storage.read(key: _userIdKey);
  }

  // Limpiar datos cuando el alumno cierre sesión (Log out)
  Future<void> clearAuthData() async {
    await _storage.delete(key: _tokenKey);
    await _storage.delete(key: _userIdKey);
  }
}