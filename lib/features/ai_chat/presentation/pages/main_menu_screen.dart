import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mi_proyecto_crud/features/ai_chat/presentation/bloc/showdown/showdown_bloc.dart';
import 'package:mi_proyecto_crud/features/ai_chat/presentation/bloc/showdown/showdown_event.dart';
import 'package:mi_proyecto_crud/features/ai_chat/presentation/pages/showdown_screen.dart';
import '../bloc/chat_bloc.dart';
import '../bloc/chat_state.dart';
import 'chat_screen.dart';
import '../../../profile/presentation/pages/brawler_selection_screen.dart';

class MainMenuScreen extends StatelessWidget {
  const MainMenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D1117),
      appBar: AppBar(
        backgroundColor: const Color(0xFF161B22),
        elevation: 0,
        title: const Text(
          "BRAWL ACADEMY",
          style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1.5, color: Colors.white),
        ),
        centerTitle: true,
      ),
      body: BlocBuilder<ChatBloc, ChatState>(
        builder: (context, state) {
          final currentBrawler = state.selectedBrawler;
          final globalTrophies = state.totalGlobalTrophies;

          return Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // 🏆 TARJETA DE PERFIL Y COPAS
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1F242C),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.amber.withOpacity(0.4), width: 2),
                  ),
                  child: Row(
                    children: [
                      // Mini Avatar del brawler activo actual
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: Colors.black,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: currentBrawler.primaryColor, width: 2),
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: Image.asset(currentBrawler.avatarAsset, fit: BoxFit.contain),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Tutor Seleccionado: ${currentBrawler.name}",
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              "Total Trophies: $globalTrophies 🏆",
                              style: const TextStyle(color: Colors.amber, fontWeight: FontWeight.w900, fontSize: 14),
                            ),
                          ],
                        ),
                      ),
                      // Botón rápido para cambiar de brawler
                      IconButton(
                        icon: const Icon(Icons.swap_horiz, color: Colors.amber, size: 30),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const BrawlerSelectionScreen()),
                          );
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 30),
                
                const Text(
                  "SELECT GAME MODE",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white60, fontWeight: FontWeight.bold, fontSize: 14, letterSpacing: 1.2),
                ),
                const SizedBox(height: 16),

                // 💬 MODO 1: FRIENDLY CHAT (Tu pantalla actual)
                _buildMenuButton(
                  context,
                  title: "FRIENDLY CHAT",
                  subtitle: "Practica inglés relajado con tu tutor",
                  icon: Icons.chat_bubble,
                  color: Colors.blueAccent.shade700,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const ChatScreen()),
                    );
                  },
                ),
                const SizedBox(height: 16),

                // ⚡ MODO 2: SHOWDOWN MODE (Próximamente)
                _buildMenuButton(
                  context,
                  title: "🔥 SHOWDOWN MODE",
                  subtitle: "Sobrevive a las preguntas rápidas y gana megacopas",
                  icon: Icons.flash_on,
                  color: const Color(0xFFC2410C),
                  onTap: () {
                    // 🌟 1. DISPARAR EL EVENTO DE INICIO: Le mandamos el brawler activo al Bloc
                    context.read<ShowdownBloc>().add(StartShowdownMatchEvent(currentBrawler));

                    // 🌟 2. MOSTRAR EL MENSAJE (Opcional, el que ya tienes)
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("¡Preparando la arena de Showdown...!"),
                        duration: Duration(milliseconds: 800),
                      ),
                    );

                    // 🌟 3. NAVEGAR A LA PANTALLA
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ShowdownScreen(currentBrawler: currentBrawler),
                      ),
                    );
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildMenuButton(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFF1F242C),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withOpacity(0.5), width: 2),
          boxShadow: [
            BoxShadow(color: color.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 4)),
          ],
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 40),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 18),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(color: Colors.white60, fontSize: 12),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, color: Colors.white24, size: 16),
          ],
        ),
      ),
    );
  }
}