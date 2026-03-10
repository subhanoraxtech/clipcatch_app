import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;

  late final Dio _dio;

  ApiService._internal() {
    _dio = Dio(
      BaseOptions(
        connectTimeout: const Duration(minutes: 10),
        receiveTimeout: const Duration(minutes: 10),
      ),
    );

    // Add logging interceptor in debug mode
    if (kDebugMode) {
      _dio.interceptors.add(
        LogInterceptor(requestBody: true, responseBody: true),
      );
    }
  }

  String get _baseUrl {
    // Use local machine IP address on home network
    // This works for Android emulator, physical devices, and all platforms
    return 'http://192.168.10.245:9000';
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
        data: {'url': url, 'videoResolution': resolution},
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
