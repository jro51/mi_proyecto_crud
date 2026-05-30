import 'dart:async';
import 'dart:math' as math;
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

class _MainMenuScreenState extends State<MainMenuScreen> with TickerProviderStateMixin {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    context.read<ChatBloc>().add(RefreshGlobalTrophiesEvent());
  }

  @override
  Widget build(BuildContext context) {
    const Color celesteBlue = Color.fromARGB(255, 83, 149, 247);

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
      body: Stack(
        children: [
          // ================= 🌌 MEJORA: FONDO MODERNO DE PARTÍCULAS FLOTANTES =================
          const Positioned.fill(
            child: _FloatingParticlesBackground(
              particleColor: celesteBlue,
            ),
          ),
          
          BlocBuilder<ChatBloc, ChatState>(
            builder: (context, state) {
              final currentBrawler = (state is ChatLoaded)
                  ? state.selectedBrawler
                  : BrawlerRepository.availableBrawlers.first;

              final globalTrophies = (state is ChatLoaded) ? state.totalGlobalTrophies : 0;

              if (_currentIndex == 1) {
                return ProfileScreen(userId: userIdReal);
              }

              return TweenAnimationBuilder<double>(
                tween: Tween<double>(begin: 0.0, end: 1.0),
                duration: const Duration(milliseconds: 600),
                curve: Curves.easeOutCubic,
                builder: (context, value, child) {
                  return Transform.translate(
                    offset: Offset(0, 25 * (1 - value)),
                    child: Opacity(opacity: value, child: child),
                  );
                },
                child: SingleChildScrollView(
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
                        nombreUsuario,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 32,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 2.5,
                        ),
                      ),
                      const SizedBox(height: 20),

                      // ================= CAJA PRINCIPAL BENTO: COMMAND CENTER =================
                      _InteractiveBentoCard(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const BrawlerSelectionScreen()),
                          );
                        },
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: const Color(0xFF111827),
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(color: celesteBlue.withOpacity(0.25)),
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(3),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(color: celesteBlue, width: 2),
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
                                        _AnimatedTrophiesCounter(targetValue: globalTrophies),
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

                      // ================= PARRILLA BENTO ASIMÉTRICA CON SHIMMER =================
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: 45,
                            child: _buildAnimatedBentoCard(
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
                            child: _GlintShimmerWrapper(
                              active: true,
                              child: _buildAnimatedBentoCard(
                                title: "MODO\nSHOWDOWN",
                                description: "¡Arriesga, responde rápido y gana o pierde copas!",
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
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        backgroundColor: const Color(0xFF060910),
        selectedItemColor: celesteBlue,
        unselectedItemColor: Colors.white.withOpacity(0.35),
        selectedFontSize: 12,
        unselectedFontSize: 12,
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w900, letterSpacing: 0.5),
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_filled, size: 24), label: 'Hogar'),
          BottomNavigationBarItem(icon: Icon(Icons.person_rounded, size: 24), label: 'Perfil'),
        ],
      ),
    );
  }

  Widget _buildAnimatedBentoCard({
    required String title,
    required String description,
    required String badgeText,
    required IconData icon,
    required Color accentColor,
    required Color celesteColor,
    required VoidCallback onTap,
    bool isHighlighted = false,
  }) {
    return _InteractiveBentoCard(
      onTap: onTap,
      child: Container(
        height: 210,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: const Color(0xFF111827),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isHighlighted ? celesteColor.withOpacity(0.5) : Colors.white.withOpacity(0.05),
            width: isHighlighted ? 1.8 : 1.0,
          ),
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
                  ),
                  child: Text(
                    badgeText,
                    style: TextStyle(color: Colors.white.withOpacity(0.3), fontSize: 9, fontWeight: FontWeight.w900),
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
                  style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w900, height: 1.2),
                ),
                const SizedBox(height: 6),
                Text(
                  description,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 12, height: 1.3),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ================= COMPONENTE: SISTEMA DE PARTÍCULAS OPTIMIZADO =================
class _FloatingParticlesBackground extends StatefulWidget {
  final Color particleColor;
  const _FloatingParticlesBackground({required this.particleColor});

  @override
  State<_FloatingParticlesBackground> createState() => _FloatingParticlesBackgroundState();
}

class _FloatingParticlesBackgroundState extends State<_FloatingParticlesBackground> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final List<_Particle> _particles = [];
  final int _maxParticles = 25; // Cantidad equilibrada para no saturar la pantalla
  final math.Random _random = math.Random();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();

    // Inicializamos las partículas en posiciones aleatorias de la pantalla
    for (int i = 0; i < _maxParticles; i++) {
      _particles.add(_createParticle(initialYRandom: true));
    }
  }

  _Particle _createParticle({bool initialYRandom = false}) {
    return _Particle(
      xRatio: _random.nextDouble(),
      // Si es al inicio, se dispersan por todo el alto. Si nacen después, nacen abajo (yRatio = 1.1)
      yRatio: initialYRandom ? _random.nextDouble() : 1.4,
      radius: _random.nextDouble() * 2.5 + 0.8, // Tamaños variados y sutiles
      speed: _random.nextDouble() * 0.0012 + 0.0004, // Velocidades lentas para look premium
      opacity: _random.nextDouble() * 0.4 + 0.1, // Opacidad baja para que sea un fondo elegante
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        // Actualizamos la posición de las partículas en cada frame
        for (int i = 0; i < _particles.length; i++) {
          _particles[i].yRatio -= _particles[i].speed;
          // Si la partícula se sale por la parte superior, la reciclamos abajo
          if (_particles[i].yRatio < -0.1) {
            _particles[i] = _createParticle();
          }
        }
        return CustomPaint(
          painter: _ParticlesPainter(particles: _particles, color: widget.particleColor),
        );
      },
    );
  }
}

class _Particle {
  double xRatio; // Posición porcentual en X (0.0 a 1.0)
  double yRatio; // Posición porcentual en Y (0.0 a 1.0)
  final double radius;
  final double speed;
  final double opacity;

  _Particle({
    required this.xRatio,
    required this.yRatio,
    required this.radius,
    required this.speed,
    required this.opacity,
  });
}

class _ParticlesPainter extends CustomPainter {
  final List<_Particle> particles;
  final Color color;

  _ParticlesPainter({required this.particles, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    for (var particle in particles) {
      paint.color = color.withOpacity(particle.opacity);
      // Calculamos la posición real basada en el tamaño actual del canvas
      final double dx = particle.xRatio * size.width;
      final double dy = particle.yRatio * size.height;
      
      canvas.drawCircle(Offset(dx, dy), particle.radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _ParticlesPainter oldDelegate) => true;
}

// ================= COMPONENTE: EFECTO PRESS & SHRINK =================
class _InteractiveBentoCard extends StatefulWidget {
  final Widget child;
  final VoidCallback onTap;
  const _InteractiveBentoCard({required this.child, required this.onTap});

  @override
  State<_InteractiveBentoCard> createState() => _InteractiveBentoCardState();
}

class _InteractiveBentoCardState extends State<_InteractiveBentoCard> {
  double _scale = 1.0;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _scale = 0.96),
      onTapUp: (_) => setState(() => _scale = 1.0),
      onTapCancel: () => setState(() => _scale = 1.0),
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _scale,
        duration: const Duration(milliseconds: 100),
        curve: Curves.easeInOut,
        child: widget.child,
      ),
    );
  }
}

// ================= COMPONENTE: CONTADOR DE TROFEOS ANIMADO =================
class _AnimatedTrophiesCounter extends StatelessWidget {
  final int targetValue;
  const _AnimatedTrophiesCounter({required this.targetValue});

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<int>(
      tween: IntTween(begin: 0, end: targetValue),
      duration: const Duration(milliseconds: 1200),
      curve: Curves.easeOutExpo,
      builder: (context, value, child) {
        return Text(
          "$value TROFEOS OBTENIDOS",
          style: const TextStyle(
            color: Color(0xFFFACC15),
            fontSize: 13,
            fontWeight: FontWeight.w900,
            letterSpacing: 0.5,
          ),
        );
      },
    );
  }
}

// ================= COMPONENTE OPTIMIZADO: DESTELLO NATURAL Y FLUIDO (GLINT) =================
class _GlintShimmerWrapper extends StatefulWidget {
  final Widget child;
  final bool active;
  const _GlintShimmerWrapper({required this.child, this.active = true});

  @override
  State<_GlintShimmerWrapper> createState() => _GlintShimmerWrapperState();
}

class _GlintShimmerWrapperState extends State<_GlintShimmerWrapper> with SingleTickerProviderStateMixin {
  late AnimationController _shimmerController;

  @override
  void initState() {
    super.initState();
    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000), // Un destello ligeramente más rápido y dinámico
    );

    if (widget.active) {
      // Dispara el efecto cada 4 segundos de forma limpia
      Timer.periodic(const Duration(seconds: 4), (timer) {
        if (mounted) {
          _shimmerController.forward(from: 0.0);
        } else {
          timer.cancel();
        }
      });
    }
  }

  @override
  void dispose() {
    _shimmerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.active) return widget.child;

    return AnimatedBuilder(
      animation: _shimmerController,
      builder: (context, child) {
        // Multiplicamos el valor (0.0 a 1.0) para que el recorrido empiece mucho antes
        // y termine mucho después de los límites físicos de la tarjeta bento.
        final double translation = (_shimmerController.value * 2.4) - 0.7;

        return ShaderMask(
          blendMode: BlendMode.srcATop,
          shaderCallback: (bounds) {
            return LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              // Los stops se desplazan de forma matemática asegurando que el blanco
              // esté completamente fuera al iniciar (valores negativos) y al terminar (> 1.0)
              stops: [
                (translation - 0.25).clamp(0.0, 1.0),
                translation.clamp(0.0, 1.0),
                (translation + 0.25).clamp(0.0, 1.0),
              ],
              colors: [
                Colors.transparent,
                // Si la animación no se está ejecutando o está en los extremos absolutos,
                // forzamos a que sea transparente para evitar destellos residuales en las esquinas.
                (_shimmerController.value == 0.0 || _shimmerController.value == 1.0)
                    ? Colors.transparent 
                    : Colors.white.withOpacity(0.22), // Un toque más brillante pero fino
                Colors.transparent,
              ],
            ).createShader(bounds);
          },
          child: widget.child,
        );
      },
      child: widget.child,
    );
  }
}