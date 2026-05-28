import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class StorageService {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  static const String _tokenKey = 'jwt_token';
  static const String _userIdKey = 'user_id';
  static const String _usernameKey = 'username'; // 🌟 Nueva clave para el nombre

  // Guardar datos al iniciar sesión o registrarse
  Future<void> saveAuthData({
    required String token, 
    required int userId,
    required String username, // 🌟 Recibimos el nombre
  }) async {
    await _storage.write(key: _tokenKey, value: token);
    await _storage.write(key: _userIdKey, value: userId.toString());
    await _storage.write(key: _usernameKey, value: username); // 🌟 Guardamos el nombre
  }

  // Leer el Token para las cabeceras HTTP
  Future<String?> getToken() async {
    return await _storage.read(key: _tokenKey);
  }

  // Leer el ID del usuario
  Future<String?> getUserId() async {
    return await _storage.read(key: _userIdKey);
  }

  // 🌟 Nueva función para Leer el Nombre de Usuario
  Future<String?> getUsername() async {
    return await _storage.read(key: _usernameKey);
  }

  // Limpiar datos cuando el alumno cierre sesión (Log out)
  Future<void> clearAuthData() async {
    await _storage.delete(key: _tokenKey);
    await _storage.delete(key: _userIdKey);
    await _storage.delete(key: _usernameKey); // 🌟 Limpiamos también el nombre
  }
}