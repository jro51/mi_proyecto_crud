import 'package:flutter/material.dart';
import '../../data/models/chat_message_model.dart';

class ChatBubble extends StatelessWidget {
  final ChatMessageModel message;
  final Color brawlerColor; // 🌟 Recibe el color del tutor actual
  final VoidCallback? onPanicPressed; 

  const ChatBubble({
    super.key, 
    required this.message,
    required this.brawlerColor,
    this.onPanicPressed,
  });

  @override
  Widget build(BuildContext context) {
    final isUser = message.sender == MessageSender.user;
    
    Color bubbleColor;
    Color textColor;
    Alignment alignment;

    if (isUser) {
      alignment = Alignment.centerRight;
      bubbleColor = brawlerColor; // 🌟 Toma el color dinámico del personaje elegido
      textColor = Colors.white;
    } else {
      alignment = Alignment.centerLeft;
      bubbleColor = message.isCorrection 
          ? const Color(0xFF3A2D13) // Tono oscuro ámbar para tips
          : const Color(0xFF1A2436); // Burbuja del Brawler en modo oscuro
      textColor = message.isCorrection 
          ? const Color(0xFFFFD56B) 
          : const Color(0xFFEFEFEF); // 🌟 SOLUCIÓN: Reemplazado Colors.whiteEF por su valor real
    }

    return Align(
      alignment: alignment,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 12.0),
        padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.80, 
        ),
        decoration: BoxDecoration(
          color: bubbleColor,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(isUser ? 16 : 4),
            bottomRight: Radius.circular(isUser ? 4 : 16),
          ),
          border: message.isCorrection 
              ? Border.all(color: Colors.amber.withOpacity(0.4), width: 1)
              : Border.all(color: Colors.white.withOpacity(0.02), width: 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (!isUser && message.isCorrection) ...[
              Row(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Icon(Icons.lightbulb_outline, size: 16, color: Color(0xFFFFD56B)),
                  SizedBox(width: 4),
                  Text(
                    "Teacher's Tip",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Color(0xFFFFD56B)),
                  ),
                ],
              ),
              const SizedBox(height: 6),
            ],
            
            Text(
              message.text,
              style: TextStyle(color: textColor, fontSize: 15, height: 1.3),
            ),

            // --- SECCIÓN PANIC MODE ---
            if (!isUser) ...[
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.start, 
                children: [
                  GestureDetector(
                    onTap: onPanicPressed,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: message.isPanicExpanded 
                            ? Colors.red.withOpacity(0.15) 
                            : brawlerColor.withOpacity(0.12), 
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: message.isPanicExpanded ? Colors.redAccent.withOpacity(0.3) : brawlerColor.withOpacity(0.3),
                          width: 1
                        )
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.g_translate_rounded, 
                            size: 13, 
                            color: message.isPanicExpanded ? Colors.redAccent : brawlerColor
                          ),
                          const SizedBox(width: 6),
                          Text(
                            message.isPanicExpanded ? "Close Help" : "Panic",
                            style: TextStyle(
                              fontSize: 11, 
                              fontWeight: FontWeight.bold,
                              color: message.isPanicExpanded ? Colors.redAccent : brawlerColor
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              
              if (message.isPanicExpanded) ...[
                const SizedBox(height: 10),
                const Divider(height: 1, color: Colors.white10),
                const SizedBox(height: 8),
                
                Text(
                  message.translation ?? "Translating context...",
                  style: const TextStyle(
                    color: Colors.white70, 
                    fontSize: 14, 
                    fontStyle: FontStyle.italic
                  ),
                ),
                
                if (message.idioms != null && message.idioms!.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  const Text(
                    "Key Vocabulary:",
                    style: TextStyle(
                      fontSize: 12, 
                      fontWeight: FontWeight.bold, 
                      color: Colors.white54
                    ),
                  ),
                  const SizedBox(height: 4),
                  ...message.idioms!.map((idiom) => Padding(
                    padding: const EdgeInsets.only(bottom: 4.0),
                    child: RichText(
                      text: TextSpan(
                        // 🌟 SOLUCIÓN: Reemplazado el problemático 'Colors.white87' por const Color(0xDEFFFFFF)
                        style: const TextStyle(fontSize: 13, color: Color(0xDEFFFFFF)),
                        children: [
                          TextSpan(
                            text: "• ${idiom.phrase}: ", 
                            style: TextStyle(fontWeight: FontWeight.bold, color: brawlerColor)
                          ),
                          TextSpan(text: idiom.meaning, style: const TextStyle(color: Colors.white70)),
                        ],
                      ),
                    ),
                  )).toList(),
                ],
              ],
            ],
          ],
        ),
      ),
    );
  }
}