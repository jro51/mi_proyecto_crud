import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../ai_chat/presentation/bloc/chat_bloc.dart';
import '../../../ai_chat/presentation/bloc/chat_event.dart';
import '../../../ai_chat/presentation/bloc/chat_state.dart';

class BrawlerSelectionScreen extends StatelessWidget {
  const BrawlerSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D1117), // Fondo oscuro general
      appBar: AppBar(
        backgroundColor: const Color(0xFF161B22),
        elevation: 0,
        title: const Text(
          "Trophy Road & Tutors", 
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 18),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        centerTitle: true,
      ),
      body: BlocBuilder<ChatBloc, ChatState>(
        builder: (context, state) {
          final globalTrophies = state.totalGlobalTrophies;
          final currentBrawlersList = state.brawlersProgress;

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                // Cabecera con el total de copas global corregido
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1F242C),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.amber.withOpacity(0.3), width: 1.5),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.emoji_events, color: Colors.amber, size: 28),
                          const SizedBox(width: 10),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "Total Trophies",
                                style: TextStyle(color: Colors.white60, fontSize: 11, fontWeight: FontWeight.bold),
                              ),
                              Text(
                                "$globalTrophies 🏆",
                                style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w900),
                              ),
                            ],
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.amber.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          "${currentBrawlersList.length} / 3 Unlocked",
                          style: const TextStyle(color: Colors.amber, fontWeight: FontWeight.bold, fontSize: 12),
                        ),
                      )
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Grid View de Personajes adaptado a imágenes con fondo plano
                Expanded(
                  child: GridView.builder(
                    itemCount: currentBrawlersList.length,
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2, 
                      crossAxisSpacing: 14,
                      mainAxisSpacing: 14,
                      childAspectRatio: 0.82,
                    ),
                    itemBuilder: (context, index) {
                      final brawler = currentBrawlersList[index];
                      final isLocked = brawler.isLocked(globalTrophies);
                      final isSelected = state.selectedBrawler.id == brawler.id;

                      return GestureDetector(
                        onTap: isLocked 
                            ? () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text("¡Necesitas ${brawler.requiredTrophies} copas globales para desbloquear a ${brawler.name}!"),
                                    backgroundColor: Colors.redAccent,
                                    duration: const Duration(seconds: 2),
                                  ),
                                );
                              }
                            : () {
                                context.read<ChatBloc>().add(ChangeBrawlerEvent(brawler));
                                Navigator.pop(context);
                              },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 250),
                          decoration: BoxDecoration(
                            color: const Color(0xFF1F242C), // Fondo unificado de tarjeta
                            borderRadius: BorderRadius.circular(20),
                            border: isSelected
                                ? Border.all(color: brawler.primaryColor, width: 3)
                                : Border.all(color: Colors.white.withOpacity(0.1), width: 1.5),
                          ),
                          child: Stack(
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(10.0),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    // Contenedor interno negro para que encajen tus avatares perfectamente
                                    Expanded(
                                      child: Container(
                                        width: double.infinity,
                                        decoration: BoxDecoration(
                                          color: Colors.black, // 🌟 IGUALA el fondo negro original de la imagen
                                          borderRadius: BorderRadius.circular(14),
                                        ),
                                        clipBehavior: Clip.antiAlias,
                                        child: Hero(
                                          tag: brawler.id,
                                          child: ColorFiltered(
                                            colorFilter: isLocked
                                                ? const ColorFilter.mode(Colors.grey, BlendMode.saturation)
                                                : const ColorFilter.mode(Colors.transparent, BlendMode.multiply),
                                            child: Image.asset(
                                              brawler.avatarAsset,
                                              fit: BoxFit.contain, // Ajusta la imagen dentro de su caja negra
                                              errorBuilder: (context, error, stackTrace) => Icon(
                                                Icons.person, 
                                                size: 40, 
                                                color: isLocked ? Colors.white24 : brawler.primaryColor
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    
                                    // Nombre del Brawler
                                    Text(
                                      brawler.name,
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                        color: isLocked ? Colors.white38 : Colors.white,
                                      ),
                                    ),
                                    const SizedBox(height: 4),

                                    // Copas individuales / Requerimiento
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: Colors.black.withOpacity(0.3),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        isLocked 
                                            ? "🔒 Req: ${brawler.requiredTrophies}" 
                                            : "🏆 ${brawler.trophies} Copas",
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                          color: isLocked ? Colors.redAccent : Colors.amber,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              // Indicador de seleccionado
                              if (isSelected && !isLocked)
                                Positioned(
                                  top: 16,
                                  right: 16,
                                  child: CircleAvatar(
                                    radius: 11,
                                    backgroundColor: brawler.primaryColor,
                                    child: const Icon(Icons.check, size: 13, color: Colors.white),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}