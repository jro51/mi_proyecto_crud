enum MessageSender { user, ai }

class IdiomExplanation {
  final String phrase;
  final String meaning;

  IdiomExplanation({required this.phrase, required this.meaning});

  Map<String, dynamic> toMap() {
    return {
      'phrase': phrase,
      'meaning': meaning,
    };
  }

  factory IdiomExplanation.fromMap(Map<String, dynamic> map) {
    return IdiomExplanation(
      phrase: map['phrase'] ?? '',
      meaning: map['meaning'] ?? '',
    );
  }
}

class ChatMessageModel {
  final String text;
  final MessageSender sender;
  final DateTime timestamp;
  final bool isCorrection; 
  
  // --- PANIC MODE ---
  final String? translation;
  final List<IdiomExplanation>? idioms;
  final bool isPanicExpanded; 

  // --- TERMÓMETRO Y RETOS ---
  final int? confidenceScore; // Puntaje de 0 a 100 que dará Gemini
  final Map<String, bool>? challengeEvaluations; // Mapea el id del reto con true/false

  ChatMessageModel({
    required this.text,
    required this.sender,
    required this.timestamp,
    this.isCorrection = false,
    this.translation,
    this.idioms,
    this.isPanicExpanded = false,
    this.confidenceScore,
    this.challengeEvaluations,
  });

  // Método helper actualizado con los nuevos campos
  ChatMessageModel copyWith({
    String? text,
    MessageSender? sender,
    DateTime? timestamp,
    bool? isCorrection,
    String? translation,
    List<IdiomExplanation>? idioms,
    bool? isPanicExpanded,
    int? confidenceScore,
    Map<String, bool>? challengeEvaluations,
  }) {
    return ChatMessageModel(
      text: text ?? this.text,
      sender: sender ?? this.sender,
      timestamp: timestamp ?? this.timestamp,
      isCorrection: isCorrection ?? this.isCorrection,
      translation: translation ?? this.translation,
      idioms: idioms ?? this.idioms,
      isPanicExpanded: isPanicExpanded ?? this.isPanicExpanded,
      confidenceScore: confidenceScore ?? this.confidenceScore,
      challengeEvaluations: challengeEvaluations ?? this.challengeEvaluations,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'text': text,
      'sender': sender.name,
      'timestamp': timestamp.toIso8601String(),
      'isCorrection': isCorrection,
      'translation': translation,
      'idioms': idioms?.map((x) => x.toMap()).toList(),
      'confidenceScore': confidenceScore, 
      'challengeEvaluations': challengeEvaluations, 
    };
  }

  factory ChatMessageModel.fromMap(Map<String, dynamic> map) {
    return ChatMessageModel(
      text: map['text'] ?? '',
      sender: map['sender'] == 'user' ? MessageSender.user : MessageSender.ai,
      timestamp: DateTime.parse(map['timestamp']),
      isCorrection: map['isCorrection'] ?? false,
      translation: map['translation'],
      idioms: map['idioms'] != null
          ? List<IdiomExplanation>.from(
              map['idioms'].map((x) => IdiomExplanation.fromMap(x)))
          : null,
      confidenceScore: map['confidenceScore'],
      challengeEvaluations: map['challengeEvaluations'] != null
          ? Map<String, bool>.from(map['challengeEvaluations'])
          : null,
    );
  }
  
  bool get isUser => sender == MessageSender.user;

}