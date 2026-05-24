import 'package:mi_proyecto_crud/features/profile/data/brawler_repository.dart';
import 'package:mi_proyecto_crud/features/profile/data/models/brawler_model.dart';
import '../../data/models/chat_message_model.dart';

class ChallengeItem {
  final String id;
  final String description;
  final bool isCompleted;

  ChallengeItem({
    required this.id,
    required this.description,
    this.isCompleted = false,
  });

  ChallengeItem copyWith({bool? isCompleted}) {
    return ChallengeItem(
      id: id,
      description: description,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }
}

abstract class ChatState {
  final List<ChatMessageModel> messages;
  final int confidenceScore;
  final List<ChallengeItem> activeChallenges;
  final BrawlerModel selectedBrawler; 
  
  // 🌟 NUEVOS ESTADOS DE PROGRESO GLOBAL
  final List<BrawlerModel> brawlersProgress; // Lista de personajes con sus copas actualizadas
  final int totalGlobalTrophies;            // Suma total de las copas del usuario

  ChatState(
    this.messages, {
    this.confidenceScore = 50,
    required this.activeChallenges,
    required this.selectedBrawler,
    required this.brawlersProgress,
    required this.totalGlobalTrophies,
  });
}

class ChatInitial extends ChatState {
  ChatInitial()
      : super(
          [],
          confidenceScore: 50,
          activeChallenges: [
            ChallengeItem(id: 'used_past_simple', description: 'Usa el pasado simple (ej. played, went)'),
            ChallengeItem(id: 'asked_question', description: 'Hazle una pregunta directa a tu tutor'),
            ChallengeItem(id: 'used_connector', description: 'Usa un conector avanzado (however, because, although)'),
          ],
          selectedBrawler: BrawlerRepository.availableBrawlers.first,
          brawlersProgress: BrawlerRepository.availableBrawlers,
          // 🌟 CORRECCIÓN: Sumamos las copas iniciales que tengan tus brawlers en el repositorio en lugar de poner 0
          totalGlobalTrophies: BrawlerRepository.availableBrawlers.fold(0, (sum, brawler) => sum + brawler.trophies),
        );
}

class ChatLoading extends ChatState {
  ChatLoading(
    List<ChatMessageModel> currentHistory, {
    required int confidenceScore,
    required List<ChallengeItem> activeChallenges,
    required BrawlerModel selectedBrawler,
    required List<BrawlerModel> brawlersProgress,
    required int totalGlobalTrophies,
  }) : super(
          currentHistory, 
          confidenceScore: confidenceScore, 
          activeChallenges: activeChallenges, 
          selectedBrawler: selectedBrawler,
          brawlersProgress: brawlersProgress,
          totalGlobalTrophies: totalGlobalTrophies,
        );
}

class ChatLoaded extends ChatState {
  // 🌟 Opcional: añadimos un flag que avise a la UI si acabamos de ganar copas en este turno
  final int? trophiesGainedThisTurn;

  ChatLoaded(
    List<ChatMessageModel> messages, {
    required int confidenceScore,
    required List<ChallengeItem> activeChallenges,
    required BrawlerModel selectedBrawler,
    required List<BrawlerModel> brawlersProgress,
    required int totalGlobalTrophies,
    this.trophiesGainedThisTurn,
  }) : super(
          messages, 
          confidenceScore: confidenceScore, 
          activeChallenges: activeChallenges, 
          selectedBrawler: selectedBrawler,
          brawlersProgress: brawlersProgress,
          totalGlobalTrophies: totalGlobalTrophies,
        );
}

class ChatError extends ChatState {
  final String message;
  ChatError(
    this.message, 
    List<ChatMessageModel> currentHistory, {
    required int confidenceScore,
    required List<ChallengeItem> activeChallenges,
    required BrawlerModel selectedBrawler,
    required List<BrawlerModel> brawlersProgress,
    required int totalGlobalTrophies,
  }) : super(
          currentHistory, 
          confidenceScore: confidenceScore, 
          activeChallenges: activeChallenges, 
          selectedBrawler: selectedBrawler,
          brawlersProgress: brawlersProgress,
          totalGlobalTrophies: totalGlobalTrophies,
        );
}