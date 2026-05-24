import 'package:mi_proyecto_crud/features/ai_chat/data/models/chat_message_model.dart';
import 'package:mi_proyecto_crud/features/profile/data/models/brawler_model.dart';

abstract class ShowdownState {
  final List<ChatMessageModel> messages;
  final int hp; // 🌟 De 0 a 100
  final int powerCubes; // 🌟 Cajas recolectadas
  final int brawlersRemaining; // 🌟 Empieza en 10 y baja hasta 1
  final BrawlerModel selectedBrawler;

  ShowdownState(
    this.messages, {
    required this.hp,
    required this.powerCubes,
    required this.brawlersRemaining,
    required this.selectedBrawler,
  });
}

// Estado de cuenta regresiva: 3... 2... 1... ¡BRAWL!
class ShowdownIntro extends ShowdownState {
  final int countdown;
  ShowdownIntro({required this.countdown, required BrawlerModel brawler})
      : super([], hp: 100, powerCubes: 0, brawlersRemaining: 10, selectedBrawler: brawler);
}

// Estado activo donde el usuario está peleando/respondiendo
class ShowdownActive extends ShowdownState {
  final bool isWaitingForAi;
  final String? damageAnimationReason; // Por si queremos sacudir la pantalla al recibir daño

  ShowdownActive(
    List<ChatMessageModel> messages, {
    required int hp,
    required int powerCubes,
    required int brawlersRemaining,
    required BrawlerModel selectedBrawler,
    this.isWaitingForAi = false,
    this.damageAnimationReason,
  }) : super(messages, hp: hp, powerCubes: powerCubes, brawlersRemaining: brawlersRemaining, selectedBrawler: selectedBrawler);
}

// ¡Victoria! Quedaste #1 en el Showdown
class ShowdownVictory extends ShowdownState {
  final int trophiesGained; // Variable de la clase hija

  ShowdownVictory({
    required this.trophiesGained, // 🌟 Pasado directamente aquí
    required BrawlerModel brawler,
  }) : super(
          [], 
          hp: 100, 
          powerCubes: 5, 
          brawlersRemaining: 1, 
          selectedBrawler: brawler,
        );
}

// ¡Derrota! Te eliminaron (HP = 0)
class ShowdownGameOver extends ShowdownState {
  final int rank; // En qué posición quedaste (ej. #7)
  final int trophiesLost;
  ShowdownGameOver({required this.rank, required this.trophiesLost, required BrawlerModel brawler})
      : super([], hp: 0, powerCubes: 0, brawlersRemaining: 10 - rank, selectedBrawler: brawler);
}