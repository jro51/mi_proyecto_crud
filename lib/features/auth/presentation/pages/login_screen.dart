import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  
  // Controls toggle between login and register
  bool _isRegisterMode = false;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      final username = _usernameController.text.trim();
      final password = _passwordController.text.trim();

      if (_isRegisterMode) {
        context.read<AuthBloc>().add(
          RegisterSubmitted(username: username, password: password),
        );
      } else {
        context.read<AuthBloc>().add(
          LoginSubmitted(username: username, password: password),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1E1E24), 
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          // 💡 SOLUCIONADO: Corregido el "state declaration is" a "state is"
          if (state is AuthFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.errorMessage),
                backgroundColor: Colors.redAccent,
              ),
            );
          }
        },
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // 👑 LOGO O TÍTULO TEMÁTICO
                  // 💡 SOLUCIONADO: Cambiado FontWeight.black a FontWeight.w900 para mantener el const
                  const Text(
                    'BRAWL',
                    style: TextStyle(
                      fontSize: 40,
                      fontWeight: FontWeight.w900,
                      color: Colors.amber,
                      letterSpacing: 2,
                    ),
                  ),
                  const Text(
                    'ACADEMY',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 40),

                  // 🏯 CONTENEDOR PRINCIPAL
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2D2D34),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.purple.shade700, width: 2),
                    ),
                    child: Column(
                      children: [
                        Text(
                          _isRegisterMode ? 'CREAR CUENTA' : 'INICIAR SESIÓN',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 20),

                        // CAMPO: USERNAME
                        TextFormField(
                          controller: _usernameController,
                          style: const TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            labelText: 'Nombre de Usuario',
                            labelStyle: TextStyle(color: Colors.grey.shade400),
                            prefixIcon: const Icon(Icons.person, color: Colors.amber),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: Colors.grey),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: Colors.amber, width: 2),
                            ),
                          ),
                          validator: (value) => value == null || value.trim().isEmpty 
                              ? 'Ingresa tu usuario' 
                              : null,
                        ),
                        const SizedBox(height: 16),

                        // CAMPO: PASSWORD
                        TextFormField(
                          controller: _passwordController,
                          obscureText: true,
                          style: const TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            labelText: 'Contraseña',
                            labelStyle: TextStyle(color: Colors.grey.shade400),
                            prefixIcon: const Icon(Icons.lock, color: Colors.amber),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: Colors.grey),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: Colors.amber, width: 2),
                            ),
                          ),
                          validator: (value) => value == null || value.trim().length < 4 
                              ? 'La contraseña debe tener mínimo 4 caracteres' 
                              : null,
                        ),
                        const SizedBox(height: 24),

                        // BOTÓN DE ACCIÓN CON MANEJO DE CARGA
                        BlocBuilder<AuthBloc, AuthState>(
                          builder: (context, state) {
                            if (state is AuthLoading) {
                              return const CircularProgressIndicator(color: Colors.amber);
                            }

                            return ElevatedButton(
                              onPressed: _submitForm,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.purple.shade600,
                                foregroundColor: Colors.white,
                                minimumSize: const Size(double.infinity, 50),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: 5,
                              ),
                              child: Text(
                                _isRegisterMode ? 'REGISTRARME' : 'ENTRAR A JUGAR',
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // OPCIÓN PARA INTERCAMBIAR ENTRE LOGIN Y REGISTRO
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _isRegisterMode = !_isRegisterMode;
                        _formKey.currentState?.reset(); 
                        _usernameController.clear();
                        _passwordController.clear();
                      });
                    },
                    child: Text(
                      _isRegisterMode
                          ? '¿Ya tienes una cuenta? Inicia Sesión aquí'
                          : '¿Eres nuevo? Regístrate aquí gratis',
                      style: const TextStyle(color: Colors.amber, fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}