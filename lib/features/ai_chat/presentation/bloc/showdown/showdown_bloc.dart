import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../profile/data/models/brawler_model.dart';
import '../../../data/models/chat_message_model.dart';
import '../../../data/repositories/showdown_repository_impl.dart'; // 💡 IMPORTANTE: Tu nuevo repositorio
import 'showdown_event.dart';
import 'showdown_state.dart';

class ShowdownBloc extends Bloc<ShowdownEvent, ShowdownState> {
  // Ahora dependemos directamente de la implementación de tu repositorio HTTP
  final ShowdownRepositoryImpl _showdownRepository;
  final List<ChatMessageModel> _history = [];
  Timer? _countdownTimer;

  // Variables de control de la partida (Ahora sincronizadas por el Servidor)
  int _hp = 100;
  int _powerCubes = 0;
  int _brawlersRemaining = 10;
  String _currentQuestion = "Welcome to the Showdown arena! Prepare yourself."; // Pregunta inicial o semilla

  ShowdownBloc(this._showdownRepository) : super(ShowdownIntro(countdown: 3, brawler: _getDummyBrawler())) {
    on<StartShowdownMatchEvent>(_onStartMatch);
    on<ShowdownCountdownTickEvent>(_onCountdownTick);
    on<SendShowdownAnswerEvent>(_onSendAnswer);
    on<PoisonGasDamageEvent>(_onPoisonGasDamage);
  }

  // 1. INICIAR PARTIDA Y CUENTA REGRESIVA
  void _onStartMatch(StartShowdownMatchEvent event, Emitter<ShowdownState> emit) {
    _hp = 100;
    _powerCubes = 0;
    _brawlersRemaining = 10;
    _history.clear();
    _currentQuestion = "Welcome to the Showdown arena! Prepare yourself.";

    emit(ShowdownIntro(countdown: 3, brawler: event.brawler));

    _countdownTimer?.cancel();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      final nextTick = 3 - timer.tick;
      if (nextTick >= 0) {
        add(ShowdownCountdownTickEvent(nextTick));
      } else {
        timer.cancel();
        add(ShowdownCountdownTickEvent(-1));
      }
    });
  }

  void _onCountdownTick(ShowdownCountdownTickEvent event, Emitter<ShowdownState> emit) {
    if (event.currentTick >= 0) {
      emit(ShowdownIntro(countdown: event.currentTick, brawler: state.selectedBrawler));
    } else {
      emit(ShowdownActive(
        const [],
        hp: _hp,
        powerCubes: _powerCubes,
        brawlersRemaining: _brawlersRemaining,
        selectedBrawler: state.selectedBrawler,
      ));
    }
  }

  // 2. ENVIAR RESPUESTA AL BACKEND 
  Future<void> _onSendAnswer(SendShowdownAnswerEvent event, Emitter<ShowdownState> emit) async {
    if (state is! ShowdownActive || event.answerText.trim().isEmpty) return;

    // 1. Guardar el mensaje del alumno en el historial de pantalla
    final userMessage = ChatMessageModel(
      text: event.answerText,
      sender: MessageSender.user,
      timestamp: DateTime.now(),
    );
    _history.add(userMessage);

    // 2. Bloquear la UI mostrando la animación de carga de la IA
    emit(ShowdownActive(
      List.from(_history),
      hp: _hp,
      powerCubes: _powerCubes,
      brawlersRemaining: _brawlersRemaining,
      selectedBrawler: state.selectedBrawler,
      isWaitingForAi: true,
    ));

    try {
      // 3. LLAMADA AL BACKEND: Enviamos el estado actual para que Java y Gemini decidan
      final roundResult = await _showdownRepository.sendShowdownAction(
        userResponse: event.answerText,
        currentHp: _hp,
        powerCubes: _powerCubes,
        brawlersRemaining: _brawlersRemaining,
        currentQuestion: _currentQuestion,
      );

      // 4. Actualizamos las variables locales con lo que calculó de forma segura el servidor
      _hp = roundResult.hpRemaining;
      _powerCubes = roundResult.powerCubes;
      _brawlersRemaining = roundResult.brawlersRemaining;
      _currentQuestion = roundResult.aiQuestion; // Guardamos el nuevo ataque/pregunta de la IA

      // 5. Agregamos la nueva pregunta de la IA al historial del chat visual
      _history.add(ChatMessageModel(
        text: _currentQuestion,
        sender: MessageSender.ai,
        timestamp: DateTime.now(),
      ));

      // 6. Evaluamos las banderas de fin de juego retornadas por Spring Boot
      if (roundResult.isMatchEnded) {
        if (roundResult.isVictory) {
          emit(ShowdownVictory(
            trophiesGained: 15, // 🌟 ¡Felicidades! MySQL ya sumó tus copas en el backend
            brawler: state.selectedBrawler,
          ));
        } else {
          emit(ShowdownGameOver(
            rank: _brawlersRemaining + 1,
            trophiesLost: 5,
            brawler: state.selectedBrawler,
          ));
        }
      } else {
        // La batalla continúa: le mandamos el 'damageReason' por si falló gramaticalmente
        emit(ShowdownActive(
          List.from(_history),
          hp: _hp,
          powerCubes: _powerCubes,
          brawlersRemaining: _brawlersRemaining,
          selectedBrawler: state.selectedBrawler,
          isWaitingForAi: false,
          damageAnimationReason: roundResult.damageReason,
        ));
      }

    } catch (e) {
      // Si el servidor falla o hay timeout, desbloqueamos la UI para que no se quede congelada
      emit(ShowdownActive(
        List.from(_history),
        hp: _hp,
        powerCubes: _powerCubes,
        brawlersRemaining: _brawlersRemaining,
        selectedBrawler: state.selectedBrawler,
        isWaitingForAi: false,
        damageAnimationReason: "Error al conectar con el servidor. Reintenta tu ataque.",
      ));
    }
  }

  // 3. DAÑO POR EL GAS VENENOSO (TIMER LOCAL)
  void _onPoisonGasDamage(PoisonGasDamageEvent event, Emitter<ShowdownState> emit) {
    if (state is! ShowdownActive) return;

    _hp -= 15;

    if (_hp <= 0) {
      emit(ShowdownGameOver(
        rank: _brawlersRemaining + 1,
        trophiesLost: 5,
        brawler: state.selectedBrawler,
      ));
    } else {
      emit(ShowdownActive(
        List.from(_history),
        hp: _hp,
        powerCubes: _powerCubes,
        brawlersRemaining: _brawlersRemaining,
        selectedBrawler: state.selectedBrawler,
        damageAnimationReason: "¡El gas venenoso te está alcanzando! (-15 HP)",
      ));
    }
  }

  @override
  Future<void> close() {
    _countdownTimer?.cancel();
    return super.close();
  }

  static BrawlerModel _getDummyBrawler() {
    return BrawlerModel(
      id: 'shelly',
      name: 'Shelly',
      avatarAsset: 'assets/images/brawlers/shelly.png',
      primaryColor: const Color(0xFF9333EA),
      requiredTrophies: 0,
      systemInstruction: '',
    );
  }
}