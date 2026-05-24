import 'package:dio/dio.dart';
import '../../../../core/network/http_client.dart';
import '../models/round_response_model.dart';

class ShowdownRepositoryImpl {
  final HttpClient _httpClient;

  ShowdownRepositoryImpl({required HttpClient httpClient}) : _httpClient = httpClient;

  // Enviamos la respuesta del alumno a Spring Boot para que valide con la IA, 
  // descuente HP si falló, y devuelva el estado de la partida actualizado de forma segura.
  Future<RoundResponseModel> sendShowdownAction({
    required String userResponse,
    required int currentHp,
    required int powerCubes,
    required int brawlersRemaining,
    required String currentQuestion,
  }) async {
    try {
      // Mapeamos el cuerpo del JSON tal como lo espera Record/DTO en Java
      final response = await _httpClient.client.post(
        '/showdown/round',
        data: {
          'userResponse': userResponse,
          'hpRemaining': currentHp,
          'powerCubes': powerCubes,
          'brawlersRemaining': brawlersRemaining,
          'currentQuestion': currentQuestion,
        },
      );

      if (response.statusCode == 200) {
        // Usamos el factory de nuestro modelo para parsear la respuesta limpia
        return RoundResponseModel.fromJson(response.data as Map<String, dynamic>);
      } else {
        throw Exception('Error inesperado del servidor en el Showdown');
      }
    } on DioException catch (e) {
      final errorMessage = e.response?.data['message'] ?? 'Error de conexión con el coliseo';
      throw Exception(errorMessage);
    }
  }
}