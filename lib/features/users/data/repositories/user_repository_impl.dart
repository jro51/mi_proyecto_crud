import 'package:dio/dio.dart';
import 'package:mi_proyecto_crud/core/network/http_client.dart';
import 'package:mi_proyecto_crud/core/services/storage_service.dart';
import 'package:mi_proyecto_crud/features/profile/data/models/user_model.dart';

class UserRepositoryImpl {
  final HttpClient _httpClient;
  final StorageService _storageService;

  UserRepositoryImpl({
    required HttpClient httpClient,
    required StorageService storageService,
  })  : _httpClient = httpClient,
        _storageService = storageService;

  Future<UserModel> getCurrentUser() async {
    final userIdStr = await _storageService.getUserId();
    final userId = int.tryParse(userIdStr ?? '0') ?? 0;

    if (userId == 0) {
      throw Exception('Sesión no encontrada. Por favor inicia sesión nuevamente.');
    }

    try {
      final response = await _httpClient.client.get('/users/$userId');
      if (response.statusCode == 200) {
        return UserModel.fromJson(response.data as Map<String, dynamic>);
      }
      throw Exception('Error al obtener el perfil del usuario.');
    } on DioException catch (e) {
      final message = e.response?.data is Map
          ? e.response?.data['message'] ?? 'Error de conexión'
          : 'Error de conexión';
      throw Exception(message);
    }
  }

  Future<UserModel> updateUsername(int userId, String newUsername) async {
  try {
    final response = await _httpClient.client.put(
      '/users/$userId/username',
      data: {
        'newUsername': newUsername,
      },
    );

    if (response.statusCode == 200) {
      return UserModel.fromJson(response.data as Map<String, dynamic>);
    } else {
      throw Exception('Error al actualizar el nombre en el servidor');
    }
  } on DioException catch (e) {
    final errorMessage = e.response?.data is Map
        ? e.response?.data['message'] ?? 'Error de servidor'
        : 'Error de conexión';
    throw Exception(errorMessage);
  }
}
}