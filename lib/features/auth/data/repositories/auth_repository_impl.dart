import 'package:dio/dio.dart';
import '../../../../core/network/http_client.dart';
import '../../../../core/services/storage_service.dart';
import '../../domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final HttpClient _httpClient;
  final StorageService _storageService;

  AuthRepositoryImpl({
    required HttpClient httpClient,
    required StorageService storageService,
  })  : _httpClient = httpClient,
        _storageService = storageService;

  @override
  Future<Map<String, dynamic>> login({required String username, required String password}) async {
    try {
      print("🚀 ENVIANDO PETICIÓN POST A /auth/login CON EL CLIENTE DIO...");
      final response = await _httpClient.client.post(
        '/auth/login',
        data: {
          'username': username,
          'password': password,
        },
      );

      print("✅ RESPUESTA DEL BACKEND RECIBIDA: ${response.statusCode}");

      if (response.statusCode == 200) {
        print("🔍 ANALIZANDO JSON RECIBIDO: ${response.data}");
        
        final data = response.data as Map<String, dynamic>;
        print("1️⃣ JSON mapeado correctamente.");

        final token = data['token'] as String;
        print("2️⃣ Token extraído: $token");

        // Cambiamos a una conversión ultra-segura por si el ID viene nulo o con otro formato
        final userId = data['userId'] != null ? (data['userId'] as num).toInt() : 0;
        print("3️⃣ ID de usuario procesado: $userId");

        final returnedUsername = data['username'] as String? ?? username; 
        print("4️⃣ Username procesado: $returnedUsername");

        print("💾 Intentando guardar datos en FlutterSecureStorage...");
        await _storageService.saveAuthData(
          token: token, 
          userId: userId, 
          username: returnedUsername,
        );
        print("💾 ¡Guardado exitoso en el Storage!");

        return {
          'userId': userId,
          'username': returnedUsername,
        };
      }
      throw Exception('Error en la respuesta del servidor');
    } on DioException catch (e) {
      print("🚨 DIO EXCEPTION EN REPOSITORIO: ${e.message}");
      final errorMessage = e.response?.data['message'] ?? 'Error al iniciar sesión';
      throw Exception(errorMessage);
    } catch (e, stack) {
      print("🚨 ERROR GENERAL EN REPOSITORIO: $e");
      print("📌 STACK: $stack");
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> register({required String username, required String password}) async {
    try {
      final response = await _httpClient.client.post(
        '/auth/register',
        data: {
          'username': username,
          'password': password,
        },
      );

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        final token = data['token'] as String;
        final userId = (data['userId'] as num).toInt();
        final returnedUsername = data['username'] as String? ?? username;

        // Guardamos en segundo plano
        await _storageService.saveAuthData(
          token: token, 
          userId: userId, 
          username: returnedUsername,
        );

        // 🌟 DEVOLVEMOS LOS DATOS DIRECTAMENTE
        return {
          'userId': userId,
          'username': returnedUsername,
        };
      }
      throw Exception('Error en la respuesta del servidor');
    } on DioException catch (e) {
      final errorMessage = e.response?.data['message'] ?? 'Error al registrar usuario';
      throw Exception(errorMessage);
    }
  }

  @override
  Future<bool> checkAuthStatus() async {
    // Al arrancar la app, verifica si ya hay un token guardado para saltarse el Login directo al menú principal.
    final token = await _storageService.getToken();
    return token != null;
  }

  @override
  Future<void> logout() async {
    await _storageService.clearAuthData();
  }

  @override
  Future<String?> getAuthenticatedUsername() async {
    return await _storageService.getUsername();
  }

  @override
  Future<String?> getAuthenticatedUserId() async {
    return await _storageService.getUserId();
  }
}