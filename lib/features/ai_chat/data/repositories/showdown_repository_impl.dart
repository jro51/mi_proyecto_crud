import 'package:dio/dio.dart';
import '../../../../core/network/http_client.dart';
import '../models/round_response_model.dart';

class ShowdownRepositoryImpl {
  final HttpClient _httpClient;

  ShowdownRepositoryImpl({required HttpClient httpClient}) : _httpClient = httpClient;

  Future<RoundResponseModel> sendShowdownAction({
    required int userId,
    required String brawlerName,
    required String userAnswer,
    required int currentHp,
    required int currentPowerCubes,
    required int currentRound,
  }) async {
    try {
      final response = await _httpClient.client.post(
        '/showdown/round',
        data: {
          'userId': userId,
          'brawlerName': brawlerName,
          'userAnswer': userAnswer,
          'currentHp': currentHp,
          'currentPowerCubes': currentPowerCubes,
          'currentRound': currentRound,
        },
      );

      if (response.statusCode == 200) {
        return RoundResponseModel.fromJson(response.data as Map<String, dynamic>);
      } else {
        throw Exception('Error inesperado del servidor en el Showdown');
      }
    } on DioException catch (e) {
      // Ahora el backend devuelve JSON con campo 'message'
      final errorMessage = e.response?.data is Map
          ? e.response?.data['message'] ?? 'Error de conexión con el coliseo'
          : 'Error de conexión con el coliseo';
      throw Exception(errorMessage);
    }
  }
}