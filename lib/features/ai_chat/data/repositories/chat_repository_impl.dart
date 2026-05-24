import 'package:dio/dio.dart';
import 'package:mi_proyecto_crud/features/ai_chat/presentation/bloc/chat_state.dart';
import '../../../../core/network/http_client.dart'; // Ajusta esta ruta según tu HttpClient core
import '../models/chat_message_model.dart';

class ChatRepositoryImpl {
  final HttpClient _httpClient;

  ChatRepositoryImpl({required HttpClient httpClient}) : _httpClient = httpClient;

  /// Envía el mensaje de la Tutoría Libre a Spring Boot.
  /// El backend procesa con Gemini, evalúa los retos y devuelve la respuesta estructurada.
  Future<ChatMessageModel> sendChatMessage({
    required String userMessage,
    required String brawlerId,
    required List<ChallengeItem> activeChallenges,
  }) async {
    try {
      // Serializamos los retos activos para mandárselos al backend
      final List<Map<String, dynamic>> challengesJson = activeChallenges.map((c) => {
        'id': c.id,
        'description': c.description,
        'isCompleted': c.isCompleted,
      }).toList();

      final response = await _httpClient.client.post(
        '/chat/message',
        data: {
          'userMessage': userMessage,
          'brawlerId': brawlerId,
          'activeChallenges': challengesJson,
        },
      );

      if (response.statusCode == 200) {
        // Mapea usando el factory fromMap que ya tiene tu ChatMessageModel
        return ChatMessageModel.fromMap(response.data as Map<String, dynamic>);
      } else {
        throw Exception('Error del servidor en la tutoría libre.');
      }
    } on DioException catch (e) {
      final errorMessage = e.response?.data['message'] ?? 'Error de comunicación con tu Tutor.';
      throw Exception(errorMessage);
    }
  }
}