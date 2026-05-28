import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mi_proyecto_crud/features/ai_chat/presentation/bloc/chat_event.dart';
import 'package:mi_proyecto_crud/features/ai_chat/presentation/bloc/showdown/showdown_bloc.dart';
import 'package:mi_proyecto_crud/features/ai_chat/presentation/bloc/showdown/showdown_event.dart';
import 'package:mi_proyecto_crud/features/ai_chat/presentation/pages/showdown_screen.dart';
import 'package:mi_proyecto_crud/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:mi_proyecto_crud/features/auth/presentation/bloc/auth_state.dart';
import 'package:mi_proyecto_crud/features/profile/data/brawler_repository.dart';
import 'package:mi_proyecto_crud/features/profile/presentation/pages/profile_screen.dart';
import '../bloc/chat_bloc.dart';
import '../bloc/chat_state.dart';
import 'chat_screen.dart';
import '../../../profile/presentation/pages/brawler_selection_screen.dart';

class MainMenuScreen extends StatefulWidget {
  const MainMenuScreen({super.key});

  @override
  State<MainMenuScreen> createState() => _MainMenuScreenState();
}

class _MainMenuScreenState extends State<MainMenuScreen> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    // ✅ Hecho correctamente: Sincronizamos con Spring Boot SOLO una vez al iniciar la pantalla
    context.read<ChatBloc>().add(RefreshGlobalTrophiesEvent());
  }

  @override
  Widget build(BuildContext context) {
    const Color celesteBlue = Color.fromARGB(255, 83, 149, 247);

    // 🌟 Leemos el estado actual del AuthBloc de forma reactiva
    final authState = context.watch<AuthBloc>().state;
    String nombreUsuario = "JUGADOR";
    int userIdReal = 0; 

    if (authState is Authenticated) {
      nombreUsuario = authState.username.toUpperCase();
      userIdReal = authState.userId;
    }

    return Scaffold(
      backgroundColor: const Color(0xFF060910), 
      appBar: AppBar(
        backgroundColor: const Color(0xFF060910),
        elevation: 0,
        title: const Row(
          children: [
            Icon(Icons.gavel_rounded, color: celesteBlue, size: 20),
            SizedBox(width: 8),
            Text(
              "BRAWL ACADEMY",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w900,
                letterSpacing: 3,
                color: celesteBlue,
              ),
            ),
          ],
        ),
        centerTitle: false,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: celesteBlue.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: celesteBlue.withOpacity(0.2)),
                ),
                child: const Text(
                  "VERSION 2.0",
                  style: TextStyle(
                    color: celesteBlue, 
                    fontSize: 10, 
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.8,
                  ),
                ),
              ),
            ),
          )
        ],
      ),
      body: BlocBuilder<ChatBloc, ChatState>(
        builder: (context, state) {
          final currentBrawler = (state is ChatLoaded) 
              ? state.selectedBrawler 
              : BrawlerRepository.availableBrawlers.first;
              
          final globalTrophies = (state is ChatLoaded) 
              ? state.totalGlobalTrophies 
              : 0;

          // 🗑️ Se eliminó la línea duplicada que forzaba el "jro" en texto plano

          if (_currentIndex == 1) {
            return ProfileScreen(userId: userIdReal);
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ================= BIENVENIDA CONTEXTUAL =================
                Text(
                  "BIENVENIDO DE NUEVO, ",
                  style: TextStyle(
                    color: celesteBlue.withOpacity(0.6), 
                    fontSize: 13, 
                    fontWeight: FontWeight.w900, 
                    letterSpacing: 2.0,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  nombreUsuario, // 🌟 Renderiza impecable el estado del AuthBloc sin hardcodeos
                  style: const TextStyle(
                    color: Colors.white, 
                    fontSize: 32, 
                    fontWeight: FontWeight.w900, 
                    letterSpacing: 2.5,
                  ),
                ),
                const SizedBox(height: 20),
                
                // ================= CAJA PRINCIPAL BENTO: BRAWLER COMMAND CENTER =================
                InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const BrawlerSelectionScreen()),
                    );
                  },
                  borderRadius: BorderRadius.circular(18),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: const Color(0xFF111827),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: celesteBlue.withOpacity(0.25)),
                      boxShadow: [
                        BoxShadow(
                          color: celesteBlue.withOpacity(0.03),
                          blurRadius: 15,
                          offset: const Offset(0, 5),
                        )
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(3),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: celesteBlue, width: 2),
                            boxShadow: [
                              BoxShadow(
                                color: celesteBlue.withOpacity(0.3),
                                blurRadius: 8,
                              )
                            ],
                          ),
                          child: CircleAvatar(
                            radius: 32,
                            backgroundColor: const Color(0xFF060910),
                            backgroundImage: AssetImage(currentBrawler.avatarAsset),
                          ),
                        ),
                        const SizedBox(width: 18),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "BRAWLER SELECCIONADO",
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.4), 
                                  fontSize: 11, 
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 1.2,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                currentBrawler.name.toUpperCase(),
                                style: const TextStyle(
                                  color: Colors.white, 
                                  fontSize: 22, 
                                  fontWeight: FontWeight.w900, 
                                  letterSpacing: 1.5,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  const Icon(Icons.emoji_events_rounded, color: Color(0xFFFACC15), size: 16),
                                  const SizedBox(width: 6),
                                  Text(
                                    "$globalTrophies TROFEOS OBTENIDOS",
                                    style: const TextStyle(
                                      color: Color(0xFFFACC15), 
                                      fontSize: 13, 
                                      fontWeight: FontWeight.w900,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        Icon(Icons.swap_horiz_rounded, color: celesteBlue.withOpacity(0.7), size: 24),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 28),
                
                Text(
                  "MODOS DE APRENDIZAJE",
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.3), 
                    fontSize: 13, 
                    fontWeight: FontWeight.w900,
                    letterSpacing: 2.0,
                  ),
                ),
                const SizedBox(height: 12),

                // ================= PARRILLA BENTO ASIMÉTRICA =================
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 45, 
                      child: _buildBentoCard(
                        title: "AI CHAT\nTUTOR",
                        description: "Práctica de conversación fluida y feedback libre.",
                        badgeText: "FREE TALK",
                        icon: Icons.smart_toy_rounded, 
                        accentColor: const Color(0xFF34C759), 
                        celesteColor: celesteBlue,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const ChatScreen()),
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: 14),
                    
                    Expanded(
                      flex: 55,
                      child: _buildBentoCard(
                        title: "MODO\nSHOWDOWN",
                        description: "¡Arriesga, responde rápido y gana o pierde copas en tiempo real!",
                        badgeText: "COMPETITIVE",
                        icon: Icons.whatshot_rounded, 
                        accentColor: const Color(0xFFFF453A), 
                        celesteColor: celesteBlue,
                        isHighlighted: true, 
                        onTap: () async {
                          context.read<ShowdownBloc>().add(StartShowdownMatchEvent(currentBrawler));
                          final resultadoCopas = await Navigator.push<dynamic>(
                            context,
                            MaterialPageRoute(builder: (context) => ShowdownScreen(currentBrawler: currentBrawler)),
                          );
                          if (resultadoCopas != null && resultadoCopas is int) {
                            context.read<ChatBloc>().add(RefreshGlobalTrophiesEvent(updatedTrophies: resultadoCopas));
                          } else {
                            context.read<ChatBloc>().add(RefreshGlobalTrophiesEvent(updatedTrophies: -5));
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
      
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(
              color: celesteBlue.withOpacity(0.15), 
              width: 1.0,
            ),
          ),
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          backgroundColor: const Color(0xFF060910), 
          selectedItemColor: celesteBlue, 
          unselectedItemColor: Colors.white.withOpacity(0.35), 
          selectedFontSize: 12,
          unselectedFontSize: 12,
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w900, letterSpacing: 0.5),
          unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w700),
          type: BottomNavigationBarType.fixed, 
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_filled, size: 24),
              label: 'Hogar',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_rounded, size: 24),
              label: 'Perfil',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBentoCard({
    required String title,
    required String description,
    required String badgeText,
    required IconData icon,
    required Color accentColor,
    required Color celesteColor,
    required VoidCallback onTap,
    bool isHighlighted = false,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        height: 210, 
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: const Color(0xFF111827),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isHighlighted 
                ? celesteColor.withOpacity(0.4) 
                : Colors.white.withOpacity(0.05),
            width: isHighlighted ? 1.5 : 1.0,
          ),
          boxShadow: isHighlighted ? [
            BoxShadow(
              color: celesteColor.withOpacity(0.02),
              blurRadius: 10,
              offset: const Offset(0, 4),
            )
          ] : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: accentColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: accentColor, size: 20),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.03),
                    borderRadius: BorderRadius.circular(5),
                    border: Border.all(color: Colors.white.withOpacity(0.05)),
                  ),
                  child: Text(
                    badgeText,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.3), 
                      fontSize: 9, 
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white, 
                    fontSize: 16, 
                    fontWeight: FontWeight.w900, 
                    height: 1.2,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  description,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.4), 
                    fontSize: 12, 
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}