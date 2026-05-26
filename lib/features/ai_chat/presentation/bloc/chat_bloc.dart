import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mi_proyecto_crud/features/ai_chat/data/voice_service.dart';
import 'package:mi_proyecto_crud/features/profile/data/brawler_repository.dart';
import 'package:mi_proyecto_crud/features/profile/data/models/brawler_model.dart';
import '../../data/models/chat_message_model.dart';
import 'dart:convert'; // 👈 Asegúrate de tener este import arriba para el jsonDecode
import 'package:http/http.dart' as http; // 👈 Si usas http

// 🌟 CORREGIDO: Importamos la interfaz abstracta, no la implementación directa
import '../../domain/repositories/chat_repository.dart'; 

import 'chat_event.dart';
import 'chat_state.dart';

class ChatBloc extends Bloc<ChatEvent, ChatState> {
  // 🌟 CORREGIDO: Cambiado a ChatRepository para respetar el polimorfismo y acoplamiento débil
  final ChatRepository _chatRepository; 
  final VoiceService voiceService = VoiceService();
  final List<ChatMessageModel> _history = [];
  
  List<ChallengeItem> _currentChallenges = [
    ChallengeItem(id: 'used_past_simple', description: 'Usa el pasado simple (ej. played, went)'),
    ChallengeItem(id: 'asked_question', description: 'Hazle una pregunta directa a tu tutor'),
    ChallengeItem(id: 'used_connector', description: 'Usa un conector avanzado (however, because, although)'),
  ];
  
  int _currentScore = 50;
  BrawlerModel _currentBrawler = BrawlerRepository.availableBrawlers.first;
  List<BrawlerModel> _brawlersList = List.from(BrawlerRepository.availableBrawlers);
  int _totalGlobalTrophies = 0;

  ChatBloc(this._chatRepository) : super(ChatInitial()) {
    on<SendMessageEvent>(_onSendMessage);
    on<ClearChatEvent>(_onClearChat);
    on<TogglePanicEvent>(_onTogglePanic);
    on<ChangeBrawlerEvent>(_onChangeBrawler);
    on<RefreshGlobalTrophiesEvent>(_onRefreshGlobalTrophies);
  }

  Future<void> _onSendMessage(SendMessageEvent event, Emitter<ChatState> emit) async {
    if (event.messageText.trim().isEmpty) return;

    final userMessage = ChatMessageModel(
      text: event.messageText,
      sender: MessageSender.user,
      timestamp: DateTime.now(),
    );
    _history.add(userMessage);

    emit(ChatLoaded(
      List.from(_history),
      confidenceScore: _currentScore,
      activeChallenges: _currentChallenges,
      selectedBrawler: _currentBrawler,
      brawlersProgress: _brawlersList,
      totalGlobalTrophies: _totalGlobalTrophies,
    ));

    try {
      // 🚀 NOTA: Asegúrate de que el método en tu interfaz se llame 'sendMessage' o 'sendChatMessage' 
      // Si usas el contrato de la interfaz oficial, el método debería llamarse: _chatRepository.sendMessage(...)
      final aiResponse = await _chatRepository.sendMessage(
        _history, // Pasamos el historial si la interfaz lo requiere
        event.messageText,
      );

      _history.add(aiResponse);

      if (aiResponse.confidenceScore != null) {
        _currentScore = aiResponse.confidenceScore!;
      }

      if (aiResponse.challengeEvaluations != null) {
        _currentChallenges = _currentChallenges.map((challenge) {
          // ✅ Si ya estaba completado, se mantiene. Si Gemini lo marcó true ahora, se activa.
          // Nunca se puede "descompletar" un reto ya logrado.
          final completedByAi = aiResponse.challengeEvaluations![challenge.id] ?? false;
          final isNowCompleted = challenge.isCompleted || completedByAi;
          return challenge.copyWith(isCompleted: isNowCompleted);
        }).toList();
      }

      int trophiesGainedThisTurn = 0;

      emit(ChatLoaded(
        List.from(_history),
        confidenceScore: _currentScore,
        activeChallenges: _currentChallenges,
        selectedBrawler: _currentBrawler,
        brawlersProgress: _brawlersList,
        totalGlobalTrophies: _totalGlobalTrophies,
        trophiesGainedThisTurn: trophiesGainedThisTurn,
      ));

      voiceService.speak(aiResponse.text);

    } catch (e) {
      emit(ChatError(
        e.toString(),
        List.from(_history),
        confidenceScore: _currentScore,
        activeChallenges: _currentChallenges,
        selectedBrawler: _currentBrawler,
        brawlersProgress: _brawlersList,
        totalGlobalTrophies: _totalGlobalTrophies,
      ));
    }
  }

  void _onClearChat(ClearChatEvent event, Emitter<ChatState> emit) {
    try { voiceService.stopSpeaking(); } catch (_) {}
    _history.clear();
    _currentScore = 50;
    _currentChallenges = [
      ChallengeItem(id: 'used_past_simple', description: 'Usa el pasado simple (ej. played, went)'),
      ChallengeItem(id: 'asked_question', description: 'Hazle una pregunta directa a tu tutor'),
      ChallengeItem(id: 'used_connector', description: 'Usa un conector avanzado (however, because, although)'),
    ];
    emit(ChatLoaded(
      List.from(_history),
      confidenceScore: _currentScore,
      activeChallenges: _currentChallenges,
      selectedBrawler: _currentBrawler,
      brawlersProgress: _brawlersList,
      totalGlobalTrophies: _totalGlobalTrophies,
    ));
  }

  void _onTogglePanic(TogglePanicEvent event, Emitter<ChatState> emit) {
    if (event.index >= 0 && event.index < _history.length) {
      final oldMsg = _history[event.index];
      _history[event.index] = ChatMessageModel(
        text: oldMsg.text,
        sender: oldMsg.sender,
        timestamp: oldMsg.timestamp,
        isCorrection: oldMsg.isCorrection,
        translation: oldMsg.translation,
        idioms: oldMsg.idioms,
        confidenceScore: oldMsg.confidenceScore,
        challengeEvaluations: oldMsg.challengeEvaluations,
        isPanicExpanded: !oldMsg.isPanicExpanded,
      );
      emit(ChatLoaded(
        List.from(_history),
        confidenceScore: _currentScore,
        activeChallenges: _currentChallenges,
        selectedBrawler: _currentBrawler,
        brawlersProgress: _brawlersList,
        totalGlobalTrophies: _totalGlobalTrophies,
      ));
    }
  }

  void _onChangeBrawler(ChangeBrawlerEvent event, Emitter<ChatState> emit) {
    _currentBrawler = event.newBrawler;
    _history.clear(); 
    emit(ChatLoaded(
      List.from(_history),
      confidenceScore: _currentScore,
      activeChallenges: _currentChallenges,
      selectedBrawler: _currentBrawler,
      brawlersProgress: _brawlersList,
      totalGlobalTrophies: _totalGlobalTrophies,
    ));
  }

  Future<void> _onRefreshGlobalTrophies(
    RefreshGlobalTrophiesEvent event, 
    Emitter<ChatState> emit
  ) async {
    
    // 🚀 IMPORTANTE: Cambia el ID '1' por el ID del usuario logueado en tu App
    final String urlUser = "http://10.0.2.2:8080/api/users/1"; 
    final String urlShowdown = "http://10.0.2.2:8080/api/showdown/round";

    try {
      // 1️⃣ Si venimos de Showdown con un resultado ('victory', 'defeat' o 'abandon')
      if (event.updatedTrophies != null) {
        // Calculamos cuántas copas sumamos o restamos
        int copasCambio = 0;
        if (event.updatedTrophies == 15) copasCambio = 15;  // Victoria
        if (event.updatedTrophies == -5) copasCambio = -5;  // Derrota o Abandono

        // Notificamos al backend para que actualice en MySQL
        // (Ajusta el body de este POST según lo que reciba tu 'PlayRoundRequest' en Spring Boot)
        await http.post(
          Uri.parse(urlShowdown),
          headers: {"Content-Type": "application/json"},
          body: jsonEncode({
            "userId": 1, 
            "copasCambio": copasCambio
          }),
        );
      }

      // 2️⃣ Sincronización Automática: Consultamos las copas reales a tu UserController
      final response = await http.get(Uri.parse(urlUser));
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        // 🌟 CORREGIDO: Mapeamos usando exactamente 'globalTrophies' de tu Record de Java
        _totalGlobalTrophies = data['globalTrophies'] ?? 0; 
        print("Sincronizado con MySQL con éxito. Copas actuales: $_totalGlobalTrophies");
      }

    } catch (e) {
      print("⚠️ Error de comunicación con Spring Boot: $e");
      
      // Fallback local por si estás testeando sin servidor encendido:
      if (event.updatedTrophies != null) {
        _totalGlobalTrophies += event.updatedTrophies!;
        if (_totalGlobalTrophies < 0) _totalGlobalTrophies = 0;
      }
    }

    // Emitimos el estado con la data en tiempo real
    emit(ChatLoaded(
      List.from(_history),
      confidenceScore: _currentScore,
      activeChallenges: _currentChallenges,
      selectedBrawler: _currentBrawler,
      brawlersProgress: _brawlersList,
      totalGlobalTrophies: _totalGlobalTrophies, 
    ));
  }

}