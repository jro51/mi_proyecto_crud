import 'package:dio/dio.dart';
import 'package:mi_proyecto_crud/core/services/storage_service.dart';

class HttpClient {
  final Dio _dio;
  final StorageService _storageService;

  static const String baseUrl = 'http://10.0.2.2:8080/api';

  HttpClient({required StorageService storageService})
      : _storageService = storageService,
        _dio = Dio(BaseOptions(
          baseUrl: baseUrl,
          connectTimeout: const Duration(seconds: 15),
          receiveTimeout: const Duration(seconds: 60), // ✅ Subido a 60s
          contentType: Headers.jsonContentType,
        )) {
    _initializeInterceptors();
  }

  Dio get client => _dio;

  void _initializeInterceptors() {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          if (!options.path.contains('/auth')) {
            final token = await _storageService.getToken();
            if (token != null) {
              options.headers['Authorization'] = 'Bearer $token';
            }
          }
          return handler.next(options);
        },
        onError: (DioException e, handler) {
          print('🚨 Error en la petición HTTP [${e.response?.statusCode}]: ${e.message}');
          return handler.next(e);
        },
      ),
    );
  }
}