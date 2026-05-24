import 'package:dio/dio.dart';
import 'package:mi_proyecto_crud/core/services/storage_service.dart';

class HttpClient {
  final Dio _dio;
  final StorageService _storageService;

  // 'localhost' o '127.0.0.1' apunta al propio emulador, no a la PC.
  // Para que el emulador de Android vea el backend de Spring Boot (puerto 8080), se usa la IP '10.0.2.2'.
  // En iOS o Web, si se puede usar 'localhost'.
  static const String baseUrl = 'http://10.0.2.2:8080/api'; 

  HttpClient({required StorageService storageService})
      : _storageService = storageService,
        _dio = Dio(BaseOptions(
          baseUrl: baseUrl,
          connectTimeout: const Duration(seconds: 10), // Evita que la app se quede congelada si el server cae
          receiveTimeout: const Duration(seconds: 10),
          contentType: Headers.jsonContentType,
        )) {
    _initializeInterceptors();
  }

  // Getter para exponer la instancia configurada de Dio hacia tus repositorios
  Dio get client => _dio;

  void _initializeInterceptors() {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          // Interceptamos la petición antes de que salga al servidor
          // Si el endpoint NO es de autenticación (login/register), buscamos el JWT y lo inyectamos automáticamente
          if (!options.path.contains('/auth')) {
            final token = await _storageService.getToken();
            if (token != null) {
              options.headers['Authorization'] = 'Bearer $token';
            }
          }
          return handler.next(options); // Continúa la petición HTTP hacia Spring Boot
        },
        onError: (DioException e, handler) {
          // Captura centralizada de errores del servidor (400, 401, 500, etc.)
          print('🚨 Error en la petición HTTP [${e.response?.statusCode}]: ${e.message}');
          return handler.next(e);
        },
      ),
    );
  }
}