import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mi_proyecto_crud/features/ai_chat/data/voice_service.dart';
import 'package:mi_proyecto_crud/features/profile/data/brawler_repository.dart';
import 'package:mi_proyecto_crud/features/profile/data/models/brawler_model.dart';
import 'package:mi_proyecto_crud/features/users/data/repositories/user_repository_impl.dart';
import '../../data/models/chat_message_model.dart';
import '../../domain/repositories/chat_repository.dart';
import 'chat_event.dart';
import 'chat_state.dart';

class ChatBloc extends Bloc<ChatEvent, ChatState> {
  final ChatRepository _chatRepository;
  final UserRepositoryImpl _userRepository;
  final VoiceService voiceService = VoiceService();
  final List<ChatMessageModel> _history = [];

  List<ChallengeItem> _currentChallenges = _defaultChallenges();
  int _currentScore = 50;
  BrawlerModel _currentBrawler = BrawlerRepository.availableBrawlers.first;
  final List<BrawlerModel> _brawlersList =
      List.from(BrawlerRepository.availableBrawlers);
  int _totalGlobalTrophies = 0;

  ChatBloc(this._chatRepository, this._userRepository)
      : super(ChatInitial()) {
    on<SendMessageEvent>(_onSendMessage);
    on<ClearChatEvent>(_onClearChat);
    on<TogglePanicEvent>(_onTogglePanic);
    on<ChangeBrawlerEvent>(_onChangeBrawler);
    on<RefreshGlobalTrophiesEvent>(_onRefreshGlobalTrophies);
  }

  // ── Helpers ──────────────────────────────────────────────────────────────

  static List<ChallengeItem> _defaultChallenges() => [
        ChallengeItem(
            id: 'used_past_simple',
            description: 'Usa el pasado simple (ej. played, went)'),
        ChallengeItem(
            id: 'asked_question',
            description: 'Hazle una pregunta directa a tu tutor'),
        ChallengeItem(
            id: 'used_connector',
            description:
                'Usa un conector avanzado (however, because, although)'),
      ];

  ChatLoaded get _currentLoadedState => ChatLoaded(
        List.from(_history),
        confidenceScore: _currentScore,
        activeChallenges: _currentChallenges,
        selectedBrawler: _currentBrawler,
        brawlersProgress: _brawlersList,
        totalGlobalTrophies: _totalGlobalTrophies,
      );

  // ── Handlers ─────────────────────────────────────────────────────────────

  Future<void> _onSendMessage(
      SendMessageEvent event, Emitter<ChatState> emit) async {
    if (event.messageText.trim().isEmpty) return;

    _history.add(ChatMessageModel(
      text: event.messageText,
      sender: MessageSender.user,
      timestamp: DateTime.now(),
    ));

    emit(_currentLoadedState);

    try {
      final aiResponse =
          await _chatRepository.sendMessage(_history, event.messageText);
      _history.add(aiResponse);

      if (aiResponse.confidenceScore != null) {
        _currentScore = aiResponse.confidenceScore!;
      }

      if (aiResponse.challengeEvaluations != null) {
        _currentChallenges = _currentChallenges.map((challenge) {
          final completedByAi =
              aiResponse.challengeEvaluations![challenge.id] ?? false;
          return challenge.copyWith(
              isCompleted: challenge.isCompleted || completedByAi);
        }).toList();
      }

      emit(_currentLoadedState);
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
    try {
      voiceService.stopSpeaking();
    } catch (_) {}
    _history.clear();
    _currentScore = 50;
    _currentChallenges = _defaultChallenges();
    emit(_currentLoadedState);
  }

  void _onTogglePanic(TogglePanicEvent event, Emitter<ChatState> emit) {
    if (event.index < 0 || event.index >= _history.length) return;

    final old = _history[event.index];
    _history[event.index] = old.copyWith(isPanicExpanded: !old.isPanicExpanded);
    emit(_currentLoadedState);
  }

  void _onChangeBrawler(ChangeBrawlerEvent event, Emitter<ChatState> emit) {
    _currentBrawler = event.newBrawler;
    _history.clear();
    emit(_currentLoadedState);
  }

  Future<void> _onRefreshGlobalTrophies(
      RefreshGlobalTrophiesEvent event, Emitter<ChatState> emit) async {
    try {
      // ✅ Usa el userId real desde SecureStorage, sin hardcodear nada
      final user = await _userRepository.getCurrentUser();
      _totalGlobalTrophies = user.globalTrophies;
    } catch (e) {
      // Fallback local si no hay conexión
      if (event.updatedTrophies != null) {
        _totalGlobalTrophies =
            (_totalGlobalTrophies + event.updatedTrophies!).clamp(0, 999999);
      }
      print('⚠️ No se pudo sincronizar trofeos: $e');
    }

    emit(_currentLoadedState);
  }
}