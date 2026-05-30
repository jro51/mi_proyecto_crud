import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mi_proyecto_crud/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:mi_proyecto_crud/features/auth/presentation/bloc/auth_event.dart';
import 'package:mi_proyecto_crud/features/profile/bloc/profile_bloc.dart';
import 'package:mi_proyecto_crud/features/profile/bloc/profile_event.dart';
import 'package:mi_proyecto_crud/features/profile/bloc/profile_state.dart';
import '../../../auth/presentation/pages/login_screen.dart'; 

class ProfileScreen extends StatefulWidget {
  final int userId;

  const ProfileScreen({super.key, required this.userId});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    context.read<ProfileBloc>().add(LoadProfileEvent());
  }

  @override
  Widget build(BuildContext context) {
    const Color scaffoldBg =  Color(0xFF060910);
    const Color cardBg = Color(0xFF111827);
    const Color goldColor = Colors.amber;
    const Color particleBlue = Color.fromARGB(255, 83, 149, 247);

    return Scaffold(
      backgroundColor: scaffoldBg,
      extendBodyBehindAppBar: true, 
      appBar: AppBar(
        title: const Text(
          'PERFIL JUGADOR', 
          style: TextStyle(fontFamily: 'Impact', color: Colors.white, letterSpacing: 2, fontWeight: FontWeight.bold)
        ),
        backgroundColor: cardBg.withOpacity(0.6),
        elevation: 0,
        scrolledUnderElevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Stack(
        children: [
          // ─── EL FONDO COMPARTIDO CON TU MENÚ HOGAR ───
          const Positioned.fill(
            child: _FloatingParticlesBackground(
              particleColor: particleBlue, // Ahora son celestes como en el Home
            ),
          ),

          // Contenido principal
          SafeArea(
            child: BlocConsumer<ProfileBloc, ProfileState>(
              listener: (context, state) {
                if (state is ProfileError) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(state.message, style: const TextStyle(fontWeight: FontWeight.bold)), 
                      backgroundColor: Colors.redAccent,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              },
              builder: (context, state) {
                if (state is ProfileLoading) {
                  return const Center(child: CircularProgressIndicator(color: particleBlue));
                }

                if (state is ProfileLoaded) {
                  final user = state.user;

                  return SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 15.0),
                    child: Column(
                      children: [
                        // ─── TARJETA PRINCIPAL: AVATAR Y DATOS (Fondo unificado) ───
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: cardBg.withOpacity(0.8), // Mismo gris oscuro que el contenedor del hogar
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: Colors.grey.withOpacity(0.15), width: 1.5),
                          ),
                          child: Column(
                            children: [
                              // Avatar Minimalista con Brillo de Partículas
                              Container(
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: particleBlue.withOpacity(0.2),
                                      blurRadius: 20,
                                      spreadRadius: 2,
                                    )
                                  ],
                                ),
                                child: CircleAvatar(
                                  radius: 55,
                                  backgroundColor: scaffoldBg,
                                  child: Text(
                                    user.username.substring(0, user.username.length >= 2 ? 2 : 1).toUpperCase(),
                                    style: const TextStyle(
                                      color: Colors.white, // Se eliminó el morado
                                      fontSize: 36, 
                                      fontWeight: FontWeight.bold, 
                                      fontFamily: 'Impact'
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 20),
                              
                              // Nombre Editable limpio
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Flexible(
                                    child: Text(
                                      user.username,
                                      style: const TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.bold, fontFamily: 'Impact', letterSpacing: 0.5),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  const SizedBox(width: 5),
                                  IconButton(
                                    icon: const Icon(Icons.edit_square, color: Colors.grey, size: 22),
                                    onPressed: () => _showEditNameDialog(context, user.id, user.username), 
                                  ),
                                ],
                              ),
                              
                              // ID de Jugador Estilizado en escala de grises
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(0.3),
                                  borderRadius: BorderRadius.circular(30),
                                ),
                                child: Text(
                                  "ID: #${user.id}",
                                  style: TextStyle(color: Colors.grey.shade400, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.5),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),

                        // ─── DISTRIBUCIÓN BENTO: ESTADÍSTICAS (Acento Dorado Únicamente Aquí) ───
                        Row(
                          children: [
                            // Caja Izquierda: Copas Totales (El foco de color amarillo)
                            Expanded(
                              flex: 6,
                              child: Container(
                                height: 110,
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: cardBg.withOpacity(0.8),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(color: goldColor.withOpacity(0.4), width: 1.5),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Row(
                                      children: [
                                        Icon(Icons.emoji_events, color: goldColor, size: 22),
                                        SizedBox(width: 8),
                                        Text('COPAS', style: TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1)),
                                      ],
                                    ),
                                    Text(
                                      '${user.globalTrophies}',
                                      style: const TextStyle(color: goldColor, fontSize: 32, fontWeight: FontWeight.bold, fontFamily: 'Impact'),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(width: 14),
                            
                            // Caja Derecha: Estado del jugador en Escala de Grises limpia
                            Expanded(
                              flex: 5,
                              child: Container(
                                height: 110,
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: cardBg.withOpacity(0.8),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(color: Colors.grey.withOpacity(0.15), width: 1.5),
                                ),
                                child: const Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        Icon(Icons.check_circle_outline, color: Colors.grey, size: 22),
                                        SizedBox(width: 6),
                                        Text('ESTADO', style: TextStyle(color: Colors.grey, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
                                      ],
                                    ),
                                    Text(
                                      'ACTIVO',
                                      style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold, fontFamily: 'Impact'),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 35),

                        // ─── BOTÓN: CIERRE DE SESIÓN LIMPIO ───
                        SizedBox(
                          width: double.infinity,
                          height: 55,
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: scaffoldBg,
                              foregroundColor: Colors.redAccent,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(18),
                                side: BorderSide(color: Colors.redAccent.withOpacity(0.5), width: 1.5),
                              ),
                              elevation: 0,
                            ),
                            icon: const Icon(Icons.logout_rounded),
                            label: const Text(
                              'CERRAR SESIÓN',
                              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, fontFamily: 'Impact', letterSpacing: 1.5),
                            ),
                            onPressed: () => _handleLogout(context),
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return const Center(child: Text('No se pudo cargar el perfil', style: TextStyle(color: Colors.white, fontFamily: 'Impact')));
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showEditNameDialog(BuildContext context, int activeUserId, String currentName) {
    final controller = TextEditingController(text: currentName);

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: const Color(0xFF161B22),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: BorderSide(color: Colors.grey.withOpacity(0.2), width: 1.5),
          ),
          title: const Text('NUEVO ALIAS', style: TextStyle(color: Colors.white, fontFamily: 'Impact', letterSpacing: 1, fontSize: 18)),
          content: TextField(
            controller: controller,
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            maxLength: 14, 
            decoration: InputDecoration(
              counterStyle: const TextStyle(color: Colors.grey),
              filled: true,
              fillColor: const Color(0xFF0D1117),
              hintText: "Escribe tu nombre de usuario",
              hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade800)),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color.fromARGB(255, 83, 149, 247))),
            ),
          ),
          actions: [
            TextButton(
              child: const Text('CANCELAR', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
              onPressed: () => Navigator.pop(dialogContext),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white, 
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))
              ),
              child: const Text('GUARDAR', style: TextStyle(fontWeight: FontWeight.bold, fontFamily: 'Impact')),
              onPressed: () {
                if (controller.text.trim().isNotEmpty) {
                  context.read<ProfileBloc>().add(UpdateProfileNameEvent(
                        userId: activeUserId, 
                        newUsername: controller.text.trim(),
                      ));
                  Navigator.pop(dialogContext);
                }
              },
            ),
          ],
        );
      },
    );
  }

  void _handleLogout(BuildContext context) {
    context.read<AuthBloc>().add(LogoutRequested());

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const LoginScreen()),
      (route) => false,
    );
  }
}

// ================= COMPONENTE: SISTEMA DE PARTÍCULAS UNIFICADO =================
class _FloatingParticlesBackground extends StatefulWidget {
  final Color particleColor;
  const _FloatingParticlesBackground({required this.particleColor});

  @override
  State<_FloatingParticlesBackground> createState() => _FloatingParticlesBackgroundState();
}

class _FloatingParticlesBackgroundState extends State<_FloatingParticlesBackground> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final List<_Particle> _particles = [];
  final int _maxParticles = 25; 
  final math.Random _random = math.Random();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();

    for (int i = 0; i < _maxParticles; i++) {
      _particles.add(_createParticle(initialYRandom: true));
    }
  }

  _Particle _createParticle({bool initialYRandom = false}) {
    return _Particle(
      xRatio: _random.nextDouble(),
      yRatio: initialYRandom ? _random.nextDouble() : 1.4,
      radius: _random.nextDouble() * 2.5 + 0.8, 
      speed: _random.nextDouble() * 0.0012 + 0.0004, 
      opacity: _random.nextDouble() * 0.35 + 0.1, 
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
        for (int i = 0; i < _particles.length; i++) {
          _particles[i].yRatio -= _particles[i].speed;
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
  double xRatio; 
  double yRatio; 
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
      final double dx = particle.xRatio * size.width;
      final double dy = particle.yRatio * size.height;
      
      canvas.drawCircle(Offset(dx, dy), particle.radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _ParticlesPainter oldDelegate) => true;
}