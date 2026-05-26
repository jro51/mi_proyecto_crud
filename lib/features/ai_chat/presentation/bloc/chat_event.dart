import 'package:mi_proyecto_crud/features/profile/data/models/brawler_model.dart';

abstract class ChatEvent {}

class SendMessageEvent extends ChatEvent {
  final String messageText;
  SendMessageEvent(this.messageText);
}

class ClearChatEvent extends ChatEvent {}

class TogglePanicEvent extends ChatEvent {
  final int index;
  TogglePanicEvent(this.index);
}

class ChangeBrawlerEvent extends ChatEvent {
  final BrawlerModel newBrawler;
  ChangeBrawlerEvent(this.newBrawler);
}

class RefreshGlobalTrophiesEvent extends ChatEvent {
  // Opcional: Si desde Showdown ya tienes el entero con las copas ganadas, 
  // se lo puedes pasar directamente aquí para ahorrarte una petición HTTP.
  final int? updatedTrophies;

  RefreshGlobalTrophiesEvent({this.updatedTrophies});
}