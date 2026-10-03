import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../constants/api_constants.dart';
import 'storage_service.dart';

/// User-friendly, structured API Exception
class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final dynamic data;
  final bool isNetworkError;
  final bool isAuthError;

  const ApiException({
    required this.message,
    this.statusCode,
    this.data,
    this.isNetworkError = false,
    this.isAuthError = false,
  });

  @override
  String toString() => message;
}

/// Central Dio API Client handling base URL, timeouts, tokens, 401 redirection, and error conversion
class ApiClient {
  static ApiClient? _instance;
  late final Dio _dio;
  final StorageService _storageService;

  // Global callback for 401 unauthorized handling
  VoidCallback? onUnauthorized;

  ApiClient._(this._storageService) {
    _dio = Dio(
      BaseOptions(
        baseUrl: ApiConstants.baseUrl,
        connectTimeout: ApiConstants.connectTimeout,
        receiveTimeout: ApiConstants.receiveTimeout,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          final token = _storageService.getToken();
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          if (kDebugMode) {
            debugPrint('🌐 [API REQ] ${options.method} ${options.uri}');
          }
          return handler.next(options);
        },
        onResponse: (response, handler) {
          if (kDebugMode) {
            debugPrint('✅ [API RESP] ${response.statusCode} ${response.requestOptions.uri}');
          }
          return handler.next(response);
        },
        onError: (DioException error, handler) async {
          if (kDebugMode) {
            debugPrint('❌ [API ERROR] ${error.response?.statusCode} ${error.requestOptions.uri}: ${error.message}');
          }

          if (error.response?.statusCode == 401) {
            // Prevent redirect loops on login/signup endpoints
            final path = error.requestOptions.path;
            final isAuthEndpoint = path.contains('/auth/login') ||
                path.contains('/auth/signup') ||
                path.contains('/auth/forgot-password');

            if (!isAuthEndpoint) {
              await _storageService.clearAuthSession();
              onUnauthorized?.call();
            }
          }

          return handler.next(error);
        },
      ),
    );
  }

  static ApiClient getInstance(StorageService storage) {
    _instance ??= ApiClient._(storage);
    return _instance!;
  }

  Dio get dio => _dio;

  // Generic Request Handlers with Centralized Error Mapping
  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.get<T>(path, queryParameters: queryParameters, options: options);
    } on DioException catch (e) {
      throw _handleError(e);
    } catch (e) {
      throw ApiException(message: 'An unexpected error occurred: $e');
    }
  }

  Future<Response<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.post<T>(path, data: data, queryParameters: queryParameters, options: options);
    } on DioException catch (e) {
      throw _handleError(e);
    } catch (e) {
      throw ApiException(message: 'An unexpected error occurred: $e');
    }
  }

  Future<Response<T>> put<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.put<T>(path, data: data, queryParameters: queryParameters, options: options);
    } on DioException catch (e) {
      throw _handleError(e);
    } catch (e) {
      throw ApiException(message: 'An unexpected error occurred: $e');
    }
  }

  Future<Response<T>> delete<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.delete<T>(path, data: data, queryParameters: queryParameters, options: options);
    } on DioException catch (e) {
      throw _handleError(e);
    } catch (e) {
      throw ApiException(message: 'An unexpected error occurred: $e');
    }
  }

  ApiException _handleError(DioException e) {
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout ||
        e.type == DioExceptionType.sendTimeout) {
      return const ApiException(
        message: 'Connection timed out. Please check your internet connection.',
        isNetworkError: true,
      );
    }

    if (e.type == DioExceptionType.connectionError) {
      return const ApiException(
        message: 'Unable to connect to the atelier server. Please verify your connection.',
        isNetworkError: true,
      );
    }

    final resp = e.response;
    if (resp != null) {
      final statusCode = resp.statusCode;
      String message = 'Server error occurred.';

      if (resp.data is Map && resp.data['message'] != null) {
        message = resp.data['message'].toString();
      } else if (resp.data is String && (resp.data as String).isNotEmpty) {
        message = resp.data.toString();
      } else {
        switch (statusCode) {
          case 400:
            message = 'Invalid request parameters.';
            break;
          case 401:
            message = 'Your session has expired. Please log in again.';
            break;
          case 403:
            message = 'Access restricted to authorized patrons.';
            break;
          case 404:
            message = 'The requested resource was not found.';
            break;
          case 409:
            message = 'Conflict. This record or email already exists.';
            break;
          case 422:
            message = 'Validation failure. Please review your input.';
            break;
          case 429:
            message = 'Too many requests. Please pause before trying again.';
            break;
          case 500:
          case 502:
          case 503:
            message = 'The atelier service is momentarily unavailable. Please try again shortly.';
            break;
        }
      }

      return ApiException(
        message: message,
        statusCode: statusCode,
        data: resp.data,
        isAuthError: statusCode == 401,
      );
    }

    return ApiException(
      message: e.message ?? 'An unexpected network error occurred.',
      isNetworkError: true,
    );
  }
}
