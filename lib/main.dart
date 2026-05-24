import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart'; // 🌟 Agregado para el archivo .env

// Importaciones del Core
import 'package:mi_proyecto_crud/core/network/http_client.dart';
import 'package:mi_proyecto_crud/core/services/storage_service.dart';
import 'package:mi_proyecto_crud/features/ai_chat/domain/repositories/chat_repository.dart';

// Importaciones del Módulo Auth
import 'package:mi_proyecto_crud/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:mi_proyecto_crud/features/auth/domain/repositories/auth_repository.dart';
import 'package:mi_proyecto_crud/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:mi_proyecto_crud/features/auth/presentation/bloc/auth_event.dart';
import 'package:mi_proyecto_crud/features/auth/presentation/bloc/auth_state.dart';
import 'package:mi_proyecto_crud/features/auth/presentation/pages/login_screen.dart';

// Importaciones del Módulo de Chat e IA (Forzamos la ruta completa del paquete)

import 'package:mi_proyecto_crud/features/ai_chat/data/gemini_service.dart';
import 'package:mi_proyecto_crud/features/ai_chat/data/repositories/showdown_repository_impl.dart';
import 'package:mi_proyecto_crud/features/ai_chat/presentation/bloc/chat_bloc.dart';
import 'package:mi_proyecto_crud/features/ai_chat/presentation/bloc/chat_event.dart';
import 'package:mi_proyecto_crud/features/ai_chat/presentation/bloc/showdown/showdown_bloc.dart';

// Importaciones de tus pantallas existentes
import 'package:mi_proyecto_crud/features/ai_chat/presentation/pages/main_menu_screen.dart';

void main() async { // 🌟 Convertido a async para cargar los assets iniciales
  // 💡 POR QUÉ: Asegura que los canales nativos de Flutter estén listos antes de arrancar.
  WidgetsFlutterBinding.ensureInitialized();

  // 🌟 Cargar las variables de entorno de tu API KEY antes de inicializar Gemini
  try {
    await dotenv.load(fileName: ".env");
  } catch (e) {
    debugPrint("Advertencia: No se pudo cargar el archivo .env: $e");
  }

  // 1. Inicializamos los servicios del Core de forma única (Singletons manuales)
  final storageService = StorageService();
  final httpClient = HttpClient(storageService: storageService);

  // 2. Inicializamos las implementaciones de los repositorios
  final authRepository = AuthRepositoryImpl(
    httpClient: httpClient,
    storageService: storageService,
  );

  final showdownRepository = ShowdownRepositoryImpl(
    httpClient: httpClient,
  );
  
  // 🌟 Forzamos el tipado explícito a la interfaz ChatRepository para resolver el error del compilador
  final ChatRepository chatRepository = GeminiService(); 

  runApp(
    RepositoryProvider<AuthRepository>.value(
      value: authRepository,
      child: MultiBlocProvider(
        providers: [
          // 🔐 Gestión de sesión en MySQL/Storage
          BlocProvider<AuthBloc>(
            create: (context) => AuthBloc(authRepository: authRepository)..add(AuthCheckRequested()),
          ),
          // 💬 Chat de aprendizaje y Trophy Road
          BlocProvider<ChatBloc>(
            create: (context) => ChatBloc(chatRepository)..add(ClearChatEvent()), 
          ),
          // ⚔️ Arena de Combate Showdown
          BlocProvider<ShowdownBloc>(
            create: (context) => ShowdownBloc(showdownRepository),
          ),
        ],
        child: const BrawlAcademyApp(),
      ),
    ),
  );
}

class BrawlAcademyApp extends StatelessWidget {
  const BrawlAcademyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Brawl Academy',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: const Color(0xFF0D1117),
        primarySwatch: Colors.purple,
        useMaterial3: true,
      ),
      home: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          if (state is AuthInitial) { 
            return const Scaffold(
              backgroundColor: Color(0xff1e1e24),
              body: Center(
                child: CircularProgressIndicator(color: Colors.amber),
              ),
            );
          }
          
          if (state is Authenticated) {
            return const MainMenuScreen();
          }
          
          return const LoginScreen();
        },
      ),
    );
  }
}