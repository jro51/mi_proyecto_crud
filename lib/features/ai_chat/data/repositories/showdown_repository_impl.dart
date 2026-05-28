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
      // 📦 Aseguramos que el mapa JSON coincida exactamente con las variables de PlayRoundRequest en Java
      final Map<String, dynamic> requestData = {
        'userId': userId, // Pasa como entero nativo de Dart, idéntico al Long de Java
        'brawlerName': brawlerName,
        'userAnswer': userAnswer,
        'currentHp': currentHp,
        'currentPowerCubes': currentPowerCubes,
        'currentRound': currentRound,
      };

      // 📝 Log local para que verifiques en tu consola qué ID y qué datos están saliendo
      print("🚀 ENVIANDO AL SHOWDOWN: $requestData");

      final response = await _httpClient.client.post(
        '/showdown/round',
        data: requestData,
      );

      if (response.statusCode == 200) {
        return RoundResponseModel.fromJson(response.data as Map<String, dynamic>);
      } else {
        throw Exception('Error inesperado del servidor en el Showdown');
      }
    } on DioException catch (e) {
      // 🚨 Si el servidor responde 400, aquí leeremos el mensaje real que Jackson o Spring arrojan
      print("🚨 DETALLES DEL ERROR 400 EN DIO: ${e.response?.data}");
      
      final errorMessage = e.response?.data is Map
          ? e.response?.data['message'] ?? 'Error de formato en los datos enviados'
          : 'Error de conexión con el coliseo';
      throw Exception(errorMessage);
    }
  }
}