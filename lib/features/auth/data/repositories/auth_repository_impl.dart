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
  Future<void> login({required String username, required String password}) async {
    try {
      // Hacemos la petición POST al endpoint público del backend.
      final response = await _httpClient.client.post(
        '/auth/login',
        data: {
          'username': username,
          'password': password,
        },
      );

      // Si el servidor responde con éxito (200), extraemos los datos
      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        final token = data['token'] as String;
        final userId = data['userId'] as int;

        // Guardamos los datos de manera cifrada en el llavero del celular.
        await _storageService.saveAuthData(token: token, userId: userId);
      }
    } on DioException catch (e) {
      // Capturamos el error controlado que mandamos desde Spring Boot (BusinessException)
      final errorMessage = e.response?.data['message'] ?? 'Error al iniciar sesión';
      throw Exception(errorMessage);
    }
  }

  @override
  Future<void> register({required String username, required String password}) async {
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
        final userId = data['userId'] as int;

        await _storageService.saveAuthData(token: token, userId: userId);
      }
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
}