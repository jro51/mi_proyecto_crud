import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mi_proyecto_crud/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:mi_proyecto_crud/features/auth/presentation/bloc/auth_event.dart';
import 'package:mi_proyecto_crud/features/profile/bloc/profile_bloc.dart';
import 'package:mi_proyecto_crud/features/profile/bloc/profile_event.dart';
import 'package:mi_proyecto_crud/features/profile/bloc/profile_state.dart';
import '../../../auth/presentation/pages/login_screen.dart'; 

class ProfileScreen extends StatelessWidget {
  final int userId;

  const ProfileScreen({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    // Disparamos la carga inicial al entrar
    context.read<ProfileBloc>().add(LoadProfileEvent());

    return Scaffold(
      backgroundColor: const Color(0xFF0D1117),
      appBar: AppBar(
        title: const Text('PERFIL', style: TextStyle(fontFamily: 'Impact', color: Colors.white, letterSpacing: 1.5, fontWeight: FontWeight.w900)),
        backgroundColor: const Color(0xFF161B22),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: BlocConsumer<ProfileBloc, ProfileState>(
        listener: (context, state) {
          if (state is ProfileError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message), backgroundColor: Colors.redAccent),
            );
          }
        },
        builder: (context, state) {
          if (state is ProfileLoading) {
            return const Center(child: CircularProgressIndicator(color: Colors.purpleAccent));
          }

          if (state is ProfileLoaded) {
            final user = state.user;

            return SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  const SizedBox(height: 10),
                  // CARD CENTRAL: AVATAR Y NOMBRE MODERNO
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: const Color(0xFF161B22),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.purpleAccent.withOpacity(0.4), width: 1.5),
                    ),
                    child: Column(
                      children: [
                        // Avatar circular con brillo neón
                        Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.purpleAccent.withOpacity(0.5),
                                blurRadius: 15,
                                spreadRadius: 2,
                              )
                            ],
                          ),
                          child: CircleAvatar(
                            radius: 50,
                            backgroundColor: const Color(0xFF0D1117),
                            child: Text(
                              user.username.substring(0, user.username.length >= 2 ? 2 : 1).toUpperCase(),
                              style: const TextStyle(color: Colors.purpleAccent, fontSize: 32, fontWeight: FontWeight.bold, fontFamily: 'Impact'),
                            ),
                          ),
                        ),
                        const SizedBox(height: 15),
                        // Nombre del Jugador + Botón Editar
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              user.username,
                              style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                            ),
                            IconButton(
                              icon: const Icon(Icons.edit, color: Colors.cyanAccent, size: 20),
                              onPressed: () => _showEditNameDialog(context, user.id, user.username), 
                            ),
                          ],
                        ),
                        Text(
                          "ID: #${user.id}",
                          style: TextStyle(color: Colors.grey.shade500, fontSize: 12, letterSpacing: 1),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 25),

                  // SECCIÓN ESTADÍSTICAS (TROFEOS)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF1F1A3A), Color(0xFF161B22)],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(color: Colors.amber.withOpacity(0.3)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.emoji_events, color: Colors.amber, size: 30),
                            const SizedBox(width: 15),
                            const Text(
                              'Copas totales',
                              style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500),
                            ),
                          ],
                        ),
                        Text(
                          '${user.globalTrophies}',
                          style: const TextStyle(color: Colors.amber, fontSize: 22, fontWeight: FontWeight.bold, fontFamily: 'Impact'),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 40),

                  // BOTÓN DE CIERRE DE SESIÓN
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2D161B),
                        foregroundColor: Colors.redAccent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                          side: const BorderSide(color: Colors.redAccent, width: 1),
                        ),
                        elevation: 5,
                      ),
                      icon: const Icon(Icons.logout),
                      label: const Text(
                        'Cerrar Sesión',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 1.2),
                      ),
                      onPressed: () => _handleLogout(context),
                    ),
                  ),
                ],
              ),
            );
          }

          return const Center(child: Text('No se pudo cargar el perfil', style: TextStyle(color: Colors.white)));
        },
      ),
    );
  }

  // Cuadro de diálogo para cambiar el nombre
  void _showEditNameDialog(BuildContext context, int activeUserId, String currentName) {
    final controller = TextEditingController(text: currentName);

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: const Color(0xFF161B22),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: const BorderSide(color: Colors.cyanAccent, width: 1),
          ),
          title: const Text('NUEVO NOMBRE DE USUARIO', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
          content: TextField(
            controller: controller,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              filled: true,
              fillColor: const Color(0xFF0D1117),
              hintText: "ingresa tu nuevo nombre de usuario",
              hintStyle: const TextStyle(color: Colors.grey),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.grey.shade800)),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Colors.cyanAccent)),
            ),
          ),
          actions: [
            TextButton(
              child: const Text('CANCELAR', style: TextStyle(color: Colors.grey)),
              onPressed: () => Navigator.pop(dialogContext),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.cyanAccent, foregroundColor: Colors.black),
              child: const Text('GUARDAR', style: TextStyle(fontWeight: FontWeight.bold)),
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

  // Lógica para borrar credenciales de almacenamiento y mandar al Login
  void _handleLogout(BuildContext context) {
    context.read<AuthBloc>().add(LogoutRequested());

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const LoginScreen()),
      (route) => false,
    );
  }
}