import 'package:equatable/equatable.dart';

class RoundResponseModel extends Equatable {
  final int hpRemaining;
  final int powerCubes;
  final int brawlersRemaining;
  final String? damageReason; // Puede ser null si el alumno respondió perfecto y no sufrió daño
  final bool isMatchEnded;
  final bool isVictory;
  final String aiQuestion;

  const RoundResponseModel({
    required this.hpRemaining,
    required this.powerCubes,
    required this.brawlersRemaining,
    this.damageReason,
    required this.isMatchEnded,
    required this.isVictory,
    required this.aiQuestion,
  });

  // Mapea con precisión los campos exactos del record 'RoundResponse' de Spring Boot.
  factory RoundResponseModel.fromJson(Map<String, dynamic> json) {
    return RoundResponseModel(
      hpRemaining: json['hpRemaining'] as int,
      powerCubes: json['powerCubes'] as int,
      brawlersRemaining: json['brawlersRemaining'] as int,
      damageReason: json['damageReason'] as String?,
      isMatchEnded: json['isMatchEnded'] as bool,
      isVictory: json['isVictory'] as bool,
      aiQuestion: json['aiQuestion'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'hpRemaining': hpRemaining,
      'powerCubes': powerCubes,
      'brawlersRemaining': brawlersRemaining,
      'damageReason': damageReason,
      'isMatchEnded': isMatchEnded,
      'isVictory': isVictory,
      'aiQuestion': aiQuestion,
    };
  }

  @override
  List<Object?> get props => [
        hpRemaining,
        powerCubes,
        brawlersRemaining,
        damageReason,
        isMatchEnded,
        isVictory,
        aiQuestion,
      ];
}