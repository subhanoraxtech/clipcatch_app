import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;

  late final Dio _dio;
  
  ApiService._internal() {
    _dio = Dio(BaseOptions(
      connectTimeout: const Duration(seconds: 20),
      receiveTimeout: const Duration(seconds: 30),
    ));
    
    // Add logging interceptor in debug mode
    if (kDebugMode) {
      _dio.interceptors.add(LogInterceptor(
        requestBody: true,
        responseBody: true,
      ));
    }
  }

  String get _baseUrl {
    // If you are using a physical Android device, ensure you run:
    // adb reverse tcp:9000 tcp:9000
    // This allows the device to access your local machine's port 9000 via localhost.
    return 'http://localhost:9000';
  }

  /// Fetches available services from the API discovery endpoint.
  Future<List<String>> fetchSupportedServices() async {
    try {
      final response = await _dio.get(_baseUrl);
      if (response.statusCode == 200) {
        final data = response.data;
        final services = data['cobalt']?['services'];
        if (services != null) {
          return List<String>.from(services);
        }
      }
    } catch (e) {
      debugPrint('Error fetching services: $e');
    }
    return [];
  }

  /// Processes a media URL with the specified resolution.
  Future<Map<String, dynamic>?> processMedia({
    required String url,
    required String resolution,
  }) async {
    try {
      final response = await _dio.post(
        _baseUrl,
        data: {
          'url': url,
          'videoResolution': resolution,
        },
        options: Options(
          headers: {
            'Accept': 'application/json',
            'Content-Type': 'application/json',
          },
        ),
      );

      if (response.statusCode == 200) {
        return response.data;
      }
    } catch (e) {
      debugPrint('Error processing media: $e');
      if (e is DioException) {
        debugPrint('Dio error details: ${e.response?.data}');
      }
    }
    return null;
  }
}
