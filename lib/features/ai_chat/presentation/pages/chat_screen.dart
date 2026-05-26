// chat_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/chat_bloc.dart';
import '../bloc/chat_event.dart';
import '../bloc/chat_state.dart';
import '../../data/models/chat_message_model.dart'; // 🌟 Asegúrate de que este import sea el correcto para tu modelo
import '../widgets/chat_bubble.dart';
import '../../../profile/presentation/pages/brawler_selection_screen.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final chatBloc = context.read<ChatBloc>();
    final voiceService = chatBloc.voiceService;

    return BlocListener<ChatBloc, ChatState>(
      listenWhen: (previous, current) {
        if (previous is ChatLoaded && current is ChatLoaded) {
          if (previous.messages.isEmpty || current.messages.isEmpty) return false;
          return previous.messages.last != current.messages.last;
        }
        return previous is! ChatLoaded && current is ChatLoaded;
      },
      listener: (context, state) {
        if (state is ChatLoaded && state.messages.isNotEmpty) {
          final lastMessage = state.messages.last;
          if (!lastMessage.isUser) {
            voiceService.speak(lastMessage.text);
          }
        }
      },
      child: BlocBuilder<ChatBloc, ChatState>(
        builder: (context, state) {
          final brawlerColor = state.selectedBrawler.primaryColor;

          return Scaffold(
            body: Container(
              decoration: BoxDecoration(
                border: Border.all(color: brawlerColor.withOpacity(0.3), width: 2),
                color: const Color(0xFF0D1520),
              ),
              child: SafeArea(
                child: Column(
                  children: [
                    // --- Custom AppBar ---
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
                      child: Row(
                        children: [
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => const BrawlerSelectionScreen()),
                              );
                            },
                            child: CircleAvatar(
                              radius: 24,
                              backgroundColor: brawlerColor.withOpacity(0.2),
                              child: CircleAvatar(
                                radius: 21,
                                backgroundColor: const Color(0xFF131C2E),
                                backgroundImage: AssetImage(state.selectedBrawler.avatarAsset),
                                child: state.selectedBrawler.avatarAsset.isEmpty 
                                    ? const Icon(Icons.person, color: Colors.white) 
                                    : null,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      state.selectedBrawler.name,
                                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                                    ),
                                    const SizedBox(width: 6),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: Colors.white12,
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: const Text("+XP", style: TextStyle(fontSize: 10, color: Colors.white70, fontWeight: FontWeight.bold)),
                                    )
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    Text(
                                      "Online",
                                      style: TextStyle(fontSize: 12, color: brawlerColor, fontWeight: FontWeight.w500),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(4),
                                        child: SizedBox(
                                          height: 6,
                                          child: LinearProgressIndicator(
                                            value: state.confidenceScore / 100,
                                            backgroundColor: Colors.white10,
                                            valueColor: AlwaysStoppedAnimation<Color>(brawlerColor),
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      "${state.confidenceScore}%",
                                      style: TextStyle(fontSize: 12, color: brawlerColor, fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete_sweep_outlined, color: Colors.white38),
                            onPressed: () => chatBloc.add(ClearChatEvent()),
                          )
                        ],
                      ),
                    ),
                    
                    const Divider(height: 1, color: Colors.white10),

                    // --- PANEL DE MISIONES ---
                    Builder(
                      builder: (context) {
                        if (state is ChatInitial && state.messages.isEmpty) {
                          return const SizedBox.shrink(); 
                        }
                        final completedCount = state.activeChallenges.where((c) => c.isCompleted).length;

                        return Card(
                          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          elevation: 0,
                          color: const Color(0xFF131C2E),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: BorderSide(color: brawlerColor.withOpacity(0.15)),
                          ),
                          child: Theme(
                            data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                            child: ExpansionTile(
                              iconColor: brawlerColor,
                              collapsedIconColor: brawlerColor.withOpacity(0.7),
                              title: Row(
                                children: [
                                  Icon(Icons.flag_outlined, color: brawlerColor, size: 20),
                                  const SizedBox(width: 8),
                                  Text(
                                    "Missions $completedCount/${state.activeChallenges.length}",
                                    // 🌟 CORRECCIÓN: Cambiado de Colors.whiteEE (inválido) a Colors.white
                                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
                                  ),
                                ],
                              ),
                              children: state.activeChallenges.map((challenge) {
                                return ListTile(
                                  dense: true,
                                  leading: Icon(
                                    challenge.isCompleted ? Icons.check_circle : Icons.radio_button_unchecked,
                                    color: challenge.isCompleted ? brawlerColor : Colors.white30,
                                    size: 18,
                                  ),
                                  title: Text(
                                    challenge.description,
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: challenge.isCompleted ? Colors.white38 : Colors.white70,
                                      decoration: challenge.isCompleted ? TextDecoration.lineThrough : null,
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                        );
                      }
                    ),

                    // Área de Mensajes
                    Expanded(
                      child: Builder(
                        builder: (context) {
                          // 🌟 CORRECCIÓN: Tipado explícito de la lista para evitar errores de compilación con ChatBubble
                          List<ChatMessageModel> currentMessages = [];

                          if (state is ChatInitial) {
                            return Center(
                              child: Text(
                                "Say 'Hi!' to start talking with ${state.selectedBrawler.name}!",
                                style: const TextStyle(color: Colors.white38),
                              ),
                            );
                          }

                          if (state is ChatLoading) currentMessages = state.messages;
                          else if (state is ChatLoaded) currentMessages = state.messages;
                          else if (state is ChatError) currentMessages = state.messages;

                          _scrollToBottom();

                          return ListView.builder(
                            controller: _scrollController,
                            padding: const EdgeInsets.only(bottom: 16),
                            itemCount: currentMessages.length + (state is ChatLoading ? 1 : 0),
                            itemBuilder: (context, index) {
                              if (index == currentMessages.length) {
                                return Align(
                                  alignment: Alignment.centerLeft,
                                  child: Container(
                                    margin: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 12.0),
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF131C2E),
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    child: SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(strokeWidth: 2, color: brawlerColor),
                                    ),
                                  ),
                                );
                              }

                              return ChatBubble(
                                message: currentMessages[index],
                                brawlerColor: brawlerColor,
                                onPanicPressed: () {
                                  context.read<ChatBloc>().add(TogglePanicEvent(index));
                                },
                              );
                            },
                          );
                        }
                      ),
                    ),

                    // --- Barra de entrada inferior ---
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 10.0),
                      color: const Color(0xFF0D1520),
                      child: Row(
                        children: [
                          StatefulBuilder(
                            builder: (context, setButtonState) {
                              final isListening = voiceService.isListening;

                              return CircleAvatar(
                                backgroundColor: isListening ? Colors.red.withOpacity(0.2) : const Color(0xFF131C2E),
                                child: IconButton(
                                  icon: Icon(
                                    isListening ? Icons.mic : Icons.mic_none,
                                    color: isListening ? Colors.redAccent : Colors.white70,
                                    size: 22,
                                  ),
                                  onPressed: () {
                                    if (isListening) {
                                      voiceService.stopListening();
                                      setButtonState(() {});
                                    } else {
                                      voiceService.startListening((textRecognized) {
                                        _textController.text = textRecognized;
                                        _textController.selection = TextSelection.fromPosition(
                                          TextPosition(offset: _textController.text.length),
                                        );
                                        setButtonState(() {});
                                      });
                                      setButtonState(() {});
                                    }
                                  },
                                ),
                              );
                            },
                          ),
                          const SizedBox(width: 10),

                          Expanded(
                            child: TextField(
                              controller: _textController,
                              style: const TextStyle(color: Colors.white),
                              decoration: InputDecoration(
                                hintText: "Reply in English...",
                                hintStyle: const TextStyle(color: Colors.white30),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(color: Colors.white10, width: 1),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(color: Colors.white.withOpacity(0.05)),
                                ),
                                fillColor: const Color(0xFF1C2637),
                                filled: true,
                                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),

                          CircleAvatar(
                            backgroundColor: brawlerColor,
                            child: IconButton(
                              icon: const Icon(Icons.send, color: Colors.white, size: 18),
                              onPressed: () {
                                final text = _textController.text;
                                if (text.trim().isNotEmpty) {
                                  context.read<ChatBloc>().add(SendMessageEvent(text));
                                  _textController.clear();
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}