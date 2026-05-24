import 'package:flutter/material.dart';

class BrawlerModel {
  final String id;
  final String name;
  final String avatarAsset;       // Ruta de la imagen local
  final Color primaryColor;        // Color que adoptará el AppBar/Botones
  final String systemInstruction;  // La personalidad que le dará a la IA
  
  // 🌟 NUEVOS ATRIBUTOS DE GAMIFICACIÓN
  final int trophies;             // Copas actuales conseguidas con este Brawler
  final int requiredTrophies;     // Cuántas copas globales se necesitan para desbloquearlo

  const BrawlerModel({
    required this.id,
    required this.name,
    required this.avatarAsset,
    required this.primaryColor,
    required this.systemInstruction,
    this.trophies = 0,            // Inicializa en 0 copas
    this.requiredTrophies = 0,    // 0 significa que es un Brawler inicial (ej: Shelly)
  });

  // 🌟 Saber de forma dinámica si está bloqueado basado en las copas globales acumuladas
  bool isLocked(int globalTrophies) => globalTrophies < requiredTrophies;

  // Método copyWith fundamental para actualizar las copas en el BLoC
  BrawlerModel copyWith({
    String? id,
    String? name,
    String? avatarAsset,
    Color? primaryColor,
    String? systemInstruction,
    int? trophies,
    int? requiredTrophies,
  }) {
    return BrawlerModel(
      id: id ?? this.id,
      name: name ?? this.name,
      avatarAsset: avatarAsset ?? this.avatarAsset,
      primaryColor: primaryColor ?? this.primaryColor,
      systemInstruction: systemInstruction ?? this.systemInstruction,
      trophies: trophies ?? this.trophies,
      requiredTrophies: requiredTrophies ?? this.requiredTrophies,
    );
  }
}