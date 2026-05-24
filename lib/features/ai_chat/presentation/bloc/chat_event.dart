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