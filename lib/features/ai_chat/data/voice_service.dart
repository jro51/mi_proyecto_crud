import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_to_text.dart';

class VoiceService {
  final FlutterTts _tts = FlutterTts();
  final SpeechToText _stt = SpeechToText();
  bool _isSpeechInitialized = false;

  VoiceService() {
    _initTts();
  }

  // Configuración del motor para hablar en inglés nativo
  void _initTts() async {
    await _tts.setLanguage("en-US"); // Idioma del profesor
    await _tts.setSpeechRate(0.45);   // Velocidad cómoda para aprender (Nivel B)
    await _tts.setVolume(1.0);
    await _tts.setPitch(1.0);         // Tono de voz natural
  }

  // Método para reproducir texto en voz alta
  Future<void> speak(String text) async {
    if (text.isNotEmpty) {
      await _tts.stop(); // Detiene cualquier audio previo
      await _tts.speak(text);
    }
  }

  // Método para detener la voz si el usuario interrumpe
  Future<void> stopSpeaking() async {
    await _tts.stop();
  }

  // Inicializa el micrófono la primera vez que se use
  Future<bool> initSpeech() async {
    if (!_isSpeechInitialized) {
      _isSpeechInitialized = await _stt.initialize(
        onError: (val) => debugPrint('Error STT: $val'),
        onStatus: (val) => debugPrint('Estado STT: $val'),
      );
    }
    return _isSpeechInitialized;
  }

  // Inicia la escucha y pasa el texto reconocido en tiempo real
  void startListening(Function(String) onResult) async {
    bool available = await initSpeech();
    if (!available) return;

    await _stt.listen( // 🌟 CORREGIDO: Cambiado '_speechToText' por '_stt'
      onResult: (result) {
        if (result.recognizedWords.isNotEmpty) {
          onResult(result.recognizedWords);
        }
      },
      listenFor: const Duration(seconds: 30), // Tiempo máximo total escuchando
      pauseFor: const Duration(seconds: 5),   // Espera hasta 5 segundos de silencio antes de cortar
      // 🌟 CORREGIDO: Configuración limpia compatible con la propiedad string nativa
      listenMode: ListenMode.dictation, 
      cancelOnError: true,
      partialResults: true,
    );
  }

  // Detiene la escucha del micrófono
  void stopListening() async {
    await _stt.stop();
  }

  // Propiedad para saber si el micrófono sigue activo
  bool get isListening => _stt.isListening;
}