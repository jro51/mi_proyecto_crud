import 'dart:convert';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:mi_proyecto_crud/features/ai_chat/data/models/chat_message_model.dart';
import 'package:mi_proyecto_crud/features/ai_chat/domain/repositories/chat_repository.dart';
import 'package:mi_proyecto_crud/features/profile/data/models/user_model.dart';

class GeminiService implements ChatRepository {
  late final GenerativeModel _model;

  GeminiService() {
    final apiKey = dotenv.env['GEMINI_API_KEY'];
    if (apiKey == null || apiKey.isEmpty) {
      throw Exception('Error: GEMINI_API_KEY no encontrada en el archivo .env');
    }

    final systemPrompt = Content.system(
      "CONTEXTO GENERAL: Eres un profesor de inglés interactivo, dinámico y muy empático. "
      "Tu objetivo es ayudar al usuario a practicar su inglés conversacional de nivel intermedio para dominar un nivel B.\n\n"
      "REGLAS DE RESPUESTA:\n"
      "1. Mantén la conversación fluida haciendo preguntas cotidianas sencillas.\n"
      "2. Si el usuario te responde en español, o te dice frases como 'no sé' o 'no entiendo', explícales de forma amigable en español cómo se diría en inglés y hazle una pregunta corta de seguimiento.\n"
      "3. Si comete un error gramatical leve, corrígelo sutilmente y continúa la charla.\n"
      "4. Respuestas cortas y de estilo mensajería de chat.\n\n"
      
      "MÉTRICA DE CONFIANZA Y FLUIDEZ:\n"
      "Evalúa el último mensaje enviado por el usuario y asígnale un puntaje entero del 0 al 100 en el campo 'confidenceScore'.\n"
      "- De 0 a 40: Respuestas ultra básicas, palabras sueltas o uso excesivo de español.\n"
      "- De 41 a 75: Respuestas gramaticalmente correctas pero muy conservadoras o cortas.\n"
      "- De 76 a 100: Estructuras más complejas, uso de conectores naturales, modismos o respuestas extendidas de manera fluida.\n\n"

      "EVALUACIÓN DE RETOS OCULTOS:\n"
      "El sistema te proporcionará una lista de IDs de retos activos junto con sus criterios de cumplimiento al final de cada interacción. "
      "Debes analizar el último mensaje del usuario y marcar cada ID como true (si lo cumplió con éxito) o false (si no lo cumplió) dentro del objeto 'challengeEvaluations'.\n\n"

      "OBLIGACIÓN DE FORMATO:\n"
      "DEBES responder única y exclusivamente con una estructura JSON válida. No agregues texto introductorio ni conclusiones fuera del JSON. "
      "Cumple estrictamente el siguiente esquema:\n"
      "{\n"
      "  \"text\": \"Tu respuesta en inglés (o la explicación si aplica)\",\n"
      "  \"translation\": \"La traducción completa al español de tu campo 'text'\",\n"
      "  \"isCorrection\": true/false,\n"
      "  \"idioms\": [\n"
      "    {\"phrase\": \"palabra o modismo clave\", \"meaning\": \"significado en español\"}\n"
      "  ],\n"
      "  \"confidenceScore\": 85,\n"
      "  \"challengeEvaluations\": {\n"
      "    \"id_del_reto_1\": true,\n"
      "    \"id_del_reto_2\": false\n"
      "  }\n"
      "}"
    );

    _model = GenerativeModel(
      model: 'gemini-3.5-flash', 
      apiKey: apiKey,
      systemInstruction: systemPrompt,
    );
  }

  @override
  Future<ChatMessageModel> sendMessage(List<ChatMessageModel> history, String userMessage) async {
    try {
      // 1. Mapeamos el historial existente conservando el texto de los mensajes pasados
      final chatContent = history.map((msg) {
        final role = msg.sender == MessageSender.user ? 'user' : 'model';
        return Content(role, [TextPart(msg.text)]);
      }).toList();

      final chat = _model.startChat(history: chatContent);
      
      // 2. Disparamos el mensaje del usuario directamente hacia Gemini
      final response = await chat.sendMessage(Content.text(userMessage));

      if (response.text == null || response.text!.isEmpty) {
        throw Exception('La IA devolvió una respuesta vacía.');
      }

      // 🛠️ LIMPIEZA MANUAL EN ROBUSTO:
      String cleanedText = response.text!.trim();
      if (cleanedText.startsWith('```json')) {
        cleanedText = cleanedText.substring(7, cleanedText.length - 3).trim();
      } else if (cleanedText.startsWith('```')) {
        cleanedText = cleanedText.substring(3, cleanedText.length - 3).trim();
      }

      // Decodificamos el JSON
      final Map<String, dynamic> jsonResponse = jsonDecode(cleanedText);

      // Mapeamos el vocabulario utilizando tu clase 'IdiomExplanation'
      List<IdiomExplanation>? parsedIdioms;
      if (jsonResponse['idioms'] != null) {
        parsedIdioms = (jsonResponse['idioms'] as List).map((item) {
          return IdiomExplanation(
            phrase: item['phrase'] ?? '',
            meaning: item['meaning'] ?? '',
          );
        }).toList();
      }

      // Mapeamos las evaluaciones de los retos de forma segura
      Map<String, bool>? parsedChallenges;
      if (jsonResponse['challengeEvaluations'] != null) {
        parsedChallenges = Map<String, bool>.from(jsonResponse['challengeEvaluations']);
      }

      // 3. Retornamos el modelo completo incluyendo las nuevas métricas analizadas por la IA
      return ChatMessageModel(
        text: jsonResponse['text'] ?? '',
        sender: MessageSender.ai,
        timestamp: DateTime.now(),
        isCorrection: jsonResponse['isCorrection'] ?? false,
        translation: jsonResponse['translation'] ?? 'Traducción no disponible',
        idioms: parsedIdioms,
        isPanicExpanded: false,
        confidenceScore: jsonResponse['confidenceScore'] ?? 50, // 50 por defecto si no viene
        challengeEvaluations: parsedChallenges,
      );
    } catch (e) {
      throw Exception('Error al comunicarse con Gemini: $e');
    }
  }

  @override
  Future<UserModel> getUserProfile() {
    // TODO: implement getUserProfile
    throw UnimplementedError();
  }
}