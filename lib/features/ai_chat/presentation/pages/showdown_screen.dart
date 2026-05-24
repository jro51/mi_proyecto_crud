import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mi_proyecto_crud/features/ai_chat/data/models/chat_message_model.dart';
import 'package:mi_proyecto_crud/features/profile/data/models/brawler_model.dart';
import '../bloc/showdown/showdown_bloc.dart';
import '../bloc/showdown/showdown_event.dart';
import '../bloc/showdown/showdown_state.dart';

class ShowdownScreen extends StatefulWidget {
  final BrawlerModel currentBrawler;

  const ShowdownScreen({super.key, required this.currentBrawler});

  @override
  State<ShowdownScreen> createState() => _ShowdownScreenState();
}

class _ShowdownScreenState extends State<ShowdownScreen> {
  final TextEditingController _answerController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    // 🌟 Disparamos el evento para iniciar la cuenta regresiva al entrar
    context.read<ShowdownBloc>().add(StartShowdownMatchEvent(widget.currentBrawler));
  }

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
    _answerController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D1117),
      body: BlocConsumer<ShowdownBloc, ShowdownState>(
        listener: (context, state) {
          if (state is ShowdownActive) {
            _scrollToBottom();
            // Si la IA nos atacó, mostramos un aviso rápido en pantalla
            if (state.damageAnimationReason != null) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.damageAnimationReason!, style: const TextStyle(fontWeight: FontWeight.bold)),
                  backgroundColor: Colors.redAccent,
                  duration: const Duration(seconds: 2),
                ),
              );
            }
          }
        },
        builder: (context, state) {
          if (state is ShowdownIntro) {
            return _buildIntroOverlay(state.countdown);
          }
          if (state is ShowdownVictory) {
            return _buildEndGameScreen(context, state: state);
          }
          if (state is ShowdownGameOver) {
            return _buildEndGameScreen(context, state: state);
          }
          if (state is ShowdownActive) {
            return _buildArenaInterface(context, state);
          }
          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }

  // 1. PANTALLA DE CUENTA REGRESIVA (3, 2, 1... ¡BRAWL!)
  Widget _buildIntroOverlay(int countdown) {
    String countdownText = countdown == 0 ? "¡BRAWL!" : "$countdown";
    return Container(
      color: Colors.black.withOpacity(0.85),
      child: Center(
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          transitionBuilder: (child, animation) => ScaleTransition(scale: animation, child: child),
          child: Text(
            countdownText,
            key: ValueKey<String>(countdownText),
            style: TextStyle(
              fontSize: countdown == 0 ? 80 : 120,
              fontWeight: FontWeight.w900,
              color: countdown == 0 ? Colors.orangeAccent : Colors.amber,
              fontStyle: FontStyle.italic,
              shadows: const [Shadow(blurRadius: 20, color: Colors.black, offset: Offset(4, 4))],
            ),
          ),
        ),
      ),
    );
  }

  // 2. LA ARENA DE JUEGO ACTIVA
  Widget _buildArenaInterface(BuildContext context, ShowdownActive state) {
    return SafeArea(
      child: Column(
        children: [
          // MARCADOR SUPERIOR: SHOWDOWN STATS
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            color: const Color(0xFF161B22),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.flash_on, color: Colors.greenAccent, size: 22),
                    const SizedBox(width: 4),
                    Text(
                      "Cubes: ${state.powerCubes}",
                      style: const TextStyle(color: Colors.greenAccent, fontWeight: FontWeight.w900, fontSize: 16),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(color: Colors.red.withOpacity(0.2), borderRadius: BorderRadius.circular(12)),
                  child: Text(
                    "❤️ Brawlers Left: ${state.brawlersRemaining}",
                    style: const TextStyle(color: Colors.redAccent, fontWeight: FontWeight.w900, fontSize: 13),
                  ),
                ),
              ],
            ),
          ),

          // BARRA DE VIDA DINÁMICA (ESTILO BRAWL STARS)
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(state.selectedBrawler.name.toUpperCase(), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 12)),
                    Text("${state.hp} / 100 HP", style: const TextStyle(color: Colors.white70, fontWeight: FontWeight.bold, fontSize: 12)),
                  ],
                ),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value: state.hp / 100,
                    minHeight: 18,
                    backgroundColor: Colors.white10,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      state.hp > 40 ? Colors.green.shade600 : Colors.red.shade600,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // LISTADO DE MENSAJES DE COMBATE
          Expanded(
            child: state.messages.isEmpty
                ? Center(
                    child: Text(
                      "¡Tu tutor ${state.selectedBrawler.name} te está esperando!\nEscríbele un saludo en inglés para iniciar el combate.",
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.white38, fontSize: 14),
                    ),
                  )
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: state.messages.length,
                    itemBuilder: (context, index) {
                      final msg = state.messages[index];
                      final isUser = msg.sender == MessageSender.user;

                      return Align(
                        alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                        child: Container(
                          margin: const EdgeInsets.symmetric(vertical: 6),
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: isUser ? const Color(0xFF1D4ED8) : const Color(0xFF1F242C),
                            borderRadius: BorderRadius.only(
                              topLeft: const Radius.circular(16),
                              topRight: const Radius.circular(16),
                              bottomLeft: Radius.circular(isUser ? 16 : 0),
                              bottomRight: Radius.circular(isUser ? 0 : 16),
                            ),
                          ),
                          constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
                          child: Text(
                            msg.text,
                            style: const TextStyle(color: Colors.white, fontSize: 15),
                          ),
                        ),
                      );
                    },
                  ),
          ),

          if (state.isWaitingForAi)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 10),
              child: Text("⚡ ¡El rival está preparando su contraataque...!", style: TextStyle(color: Colors.amber, fontWeight: FontWeight.bold, fontSize: 12)),
            ),

          // CAMPO DE TEXTO PARA RESPONDER
          Padding(
            padding: const EdgeInsets.all(14.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _answerController,
                    enabled: !state.isWaitingForAi,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: "Responde de forma perfecta en inglés...",
                      hintStyle: const TextStyle(color: Colors.white38, fontSize: 14),
                      fillColor: const Color(0xFF161B22),
                      filled: true,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(24), borderSide: BorderSide.none),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                CircleAvatar(
                  backgroundColor: const Color(0xFFC2410C),
                  radius: 24,
                  child: IconButton(
                    icon: const Icon(Icons.send, color: Colors.white, size: 20),
                    onPressed: state.isWaitingForAi
                        ? null
                        : () {
                            if (_answerController.text.trim().isNotEmpty) {
                              context.read<ShowdownBloc>().add(SendShowdownAnswerEvent(_answerController.text));
                              _answerController.clear();
                            }
                          },
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 3. PANTALLA DE RESULTADOS (FIN DE JUEGO / VICTORIA)
  Widget _buildEndGameScreen(BuildContext context, {required ShowdownState state}) {
    final isVictory = state is ShowdownVictory;
    
    // Obtenemos el rango y las copas correspondientes según el estado real
    final rank = isVictory ? 1 : (state as ShowdownGameOver).rank;
    final trophiesText = isVictory 
        ? "+${(state as ShowdownVictory).trophiesGained} Copas 🏆" 
        : "-${(state as ShowdownGameOver).trophiesLost} Copas 📉";

    return Container(
      color: Colors.black.withOpacity(0.9),
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Icon(
            isVictory ? Icons.emoji_events : Icons.sentiment_very_dissatisfied,
            size: 100,
            color: isVictory ? Colors.amber : Colors.redAccent,
          ),
          const SizedBox(height: 20),
          Text(
            isVictory ? "🏆 ¡VICTORIA! 🏆" : "💥 ELIMINADO 💥",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: isVictory ? Colors.amber : Colors.redAccent, fontStyle: FontStyle.italic),
          ),
          const SizedBox(height: 8),
          Text(
            "Quedaste en la posición #$rank",
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white70, fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 30),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: const Color(0xFF1F242C), borderRadius: BorderRadius.circular(16)),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  isVictory ? "Recompensa: " : "Penalización: ",
                  style: const TextStyle(color: Colors.white, fontSize: 16),
                ),
                Text(
                  trophiesText,
                  style: TextStyle(
                    color: isVictory ? Colors.amber : Colors.redAccent, 
                    fontWeight: FontWeight.w900, 
                    fontSize: 18
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 40),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: isVictory ? Colors.amber.shade700 : Colors.redAccent.shade700,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            onPressed: () {
              // Regresar al Lobby / Menú principal
              Navigator.pop(context);
            },
            child: const Text("VOLVER AL MENÚ", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 16)),
          ),
        ],
      ),
    );
  }
}