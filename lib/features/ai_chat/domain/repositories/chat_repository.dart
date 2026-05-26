import 'package:mi_proyecto_crud/features/profile/data/models/user_model.dart';

import '../../data/models/chat_message_model.dart';

abstract class ChatRepository {
  // Envía el historial de mensajes actual junto con el nuevo mensaje del usuario,
  // y retorna la respuesta procesada de la IA.
  Future<ChatMessageModel> sendMessage(List<ChatMessageModel> history, String userMessage);

  Future<UserModel> getUserProfile();
}