import 'package:mi_proyecto_crud/features/profile/data/models/brawler_model.dart';

abstract class ShowdownEvent {}

// Inicia la partida y la cuenta regresiva
class StartShowdownMatchEvent extends ShowdownEvent {
  final BrawlerModel brawler;
  StartShowdownMatchEvent(this.brawler);
}

// Maneja el tic-tac de la cuenta regresiva inicial (3, 2, 1)
class ShowdownCountdownTickEvent extends ShowdownEvent {
  final int currentTick;
  ShowdownCountdownTickEvent(this.currentTick);
}

// Enviar la respuesta en inglés para que sea evaluada en combate
class SendShowdownAnswerEvent extends ShowdownEvent {
  final String answerText;
  SendShowdownAnswerEvent(this.answerText);
}

// El temporizador llegó a 0 (El gas venenoso te hace daño)
class PoisonGasDamageEvent extends ShowdownEvent {}