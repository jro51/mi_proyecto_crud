import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../core/services/storage_service.dart';
import '../../../../profile/data/models/brawler_model.dart';
import '../../../data/models/chat_message_model.dart';
import '../../../data/repositories/showdown_repository_impl.dart';
import 'showdown_event.dart';
import 'showdown_state.dart';

class ShowdownBloc extends Bloc<ShowdownEvent, ShowdownState> {
  final ShowdownRepositoryImpl _showdownRepository;
  final StorageService _storageService; // ✅ Inyectamos StorageService
  final List<ChatMessageModel> _history = [];
  Timer? _countdownTimer;

  int _hp = 100;
  int _powerCubes = 0;
  int _brawlersRemaining = 10;
  int _currentRound = 0; // ✅ Rastreamos la ronda
  String _currentQuestion = "Welcome to the Showdown arena! Prepare yourself.";

  ShowdownBloc(this._showdownRepository, this._storageService)
      : super(ShowdownIntro(countdown: 3, brawler: _getDummyBrawler())) {
    on<StartShowdownMatchEvent>(_onStartMatch);
    on<ShowdownCountdownTickEvent>(_onCountdownTick);
    on<SendShowdownAnswerEvent>(_onSendAnswer);
    on<PoisonGasDamageEvent>(_onPoisonGasDamage);
  }

  void _onStartMatch(StartShowdownMatchEvent event, Emitter<ShowdownState> emit) {
    _hp = 100;
    _powerCubes = 0;
    _brawlersRemaining = 10;
    _currentRound = 0; // ✅ Reset de ronda
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

  Future<void> _onSendAnswer(SendShowdownAnswerEvent event, Emitter<ShowdownState> emit) async {
    if (state is! ShowdownActive || event.answerText.trim().isEmpty) return;

    final userMessage = ChatMessageModel(
      text: event.answerText,
      sender: MessageSender.user,
      timestamp: DateTime.now(),
    );
    _history.add(userMessage);

    emit(ShowdownActive(
      List.from(_history),
      hp: _hp,
      powerCubes: _powerCubes,
      brawlersRemaining: _brawlersRemaining,
      selectedBrawler: state.selectedBrawler,
      isWaitingForAi: true,
    ));

    try {
      // ✅ Leemos el userId real desde el almacenamiento seguro
      final userIdStr = await _storageService.getUserId();
      final userId = int.tryParse(userIdStr ?? '0') ?? 0;

      if (userId == 0) {
        throw Exception('No se encontró la sesión del usuario. Por favor reinicia sesión.');
      }

      final roundResult = await _showdownRepository.sendShowdownAction(
        userId: userId,
        brawlerName: state.selectedBrawler.name,
        userAnswer: event.answerText,
        currentHp: _hp,
        currentPowerCubes: _powerCubes,
        currentRound: _currentRound,
      );

      // ✅ Actualizamos el estado con la respuesta del servidor
      _hp = roundResult.hpRemaining;
      _powerCubes = roundResult.powerCubes;
      _brawlersRemaining = roundResult.brawlersRemaining;
      _currentRound++;
      _currentQuestion = roundResult.aiQuestion;

      _history.add(ChatMessageModel(
        text: _currentQuestion,
        sender: MessageSender.ai,
        timestamp: DateTime.now(),
      ));

      if (roundResult.isMatchEnded) {
        if (roundResult.isVictory) {
          emit(ShowdownVictory(trophiesGained: 15, brawler: state.selectedBrawler));
        } else {
          emit(ShowdownGameOver(
            rank: _brawlersRemaining + 1,
            trophiesLost: 5,
            brawler: state.selectedBrawler,
          ));
        }
      } else {
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
      emit(ShowdownActive(
        List.from(_history),
        hp: _hp,
        powerCubes: _powerCubes,
        brawlersRemaining: _brawlersRemaining,
        selectedBrawler: state.selectedBrawler,
        isWaitingForAi: false,
        damageAnimationReason: "⚠️ ${e.toString().replaceAll('Exception: ', '')}",
      ));
    }
  }

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