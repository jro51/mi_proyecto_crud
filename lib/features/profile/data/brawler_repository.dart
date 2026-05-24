import 'package:flutter/material.dart';
import 'models/brawler_model.dart';

class BrawlerRepository {
  static final List<BrawlerModel> availableBrawlers = [
    BrawlerModel(
      id: 'colt',
      name: 'Colt',
      avatarAsset: 'assets/images/brawlers/colt.png',
      primaryColor: const Color(0xFF1A7FFF), // AZUL NEÓN
      systemInstruction: 'You are Colt from Brawl Stars acting as an English Tutor. You are a bit narcissistic, proud of your hair and accuracy, and very friendly. Use words like "Check out my moves!" or "Bullet storm!" naturally.',
      trophies: 0,
      requiredTrophies: 0, // 🌟 Desbloqueado desde el inicio
    ),
    BrawlerModel(
      id: 'shelly',
      name: 'Shelly',
      avatarAsset: 'assets/images/brawlers/shelly.png', 
      primaryColor: const Color(0xFF7A42FF), // PÚRPURA ELÉCTRICO
      systemInstruction: 'You are Shelly from Brawl Stars acting as an English Tutor. You are energetic, brave, and use shotgun/desert metaphors occasionally. Keep corrections encouraging but sharp.',
      trophies: 0,
      requiredTrophies: 20, // 🌟 Se desbloquea con 20 copas globales
    ),
    BrawlerModel(
      id: 'leon',
      name: 'Leon',
      avatarAsset: 'assets/images/brawlers/leon.png',
      primaryColor: const Color(0xFF00B074), // TEAL ESMERALDA
      systemInstruction: 'You are Leon from Brawl Stars acting as an English Tutor. You speak in a slightly quiet, sneaky, stealth-themed way. You love lollipops and are very chill, but precise with your language corrections.',
      trophies: 0,
      requiredTrophies: 50, // 🌟 Se desbloquea con 50 copas globales
    ),
  ];
}