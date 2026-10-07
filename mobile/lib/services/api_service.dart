import 'dart:io';
import 'package:dio/dio.dart';
import '../utils/constants.dart';
import 'storage_service.dart';

class ApiException implements Exception {
  final String message;
  final int? statusCode;
  ApiException(this.message, [this.statusCode]);

  @override
  String toString() => 'ApiException: $message (Status: $statusCode)';
}

class ApiService {
  late final Dio _dio;
  final StorageService _storageService;

  ApiService(this._storageService) {
    _dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
        headers: {'Content-Type': 'application/json'},
      ),
    );

    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await _storageService.getToken();
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        return handler.next(options);
      },
      onError: (DioException e, handler) {
        String message = 'Something went wrong';
        int? statusCode = e.response?.statusCode;

        if (e.response?.data != null && e.response?.data is Map) {
          message = e.response?.data['message'] ?? message;
        } else if (e.type == DioExceptionType.connectionTimeout ||
            e.type == DioExceptionType.receiveTimeout) {
          message = 'Connection timed out. Please try again.';
        } else if (e.error is SocketException) {
          message = 'No Internet connection.';
        } else if (statusCode == 401) {
          message = 'Invalid email or password.';
        }

        return handler.next(DioException(
          requestOptions: e.requestOptions,
          response: e.response,
          type: e.type,
          error: ApiException(message, statusCode),
        ));
      },
    ));
  }

  Future<Map<String, dynamic>> post(String path, {dynamic data}) async {
    try {
      final response = await _dio.post(path, data: data);
      return response.data as Map<String, dynamic>;
    } catch (e) {
      _throwError(e);
    }
  }

  Future<Map<String, dynamic>> get(String path, {Map<String, dynamic>? queryParameters}) async {
    try {
      final response = await _dio.get(path, queryParameters: queryParameters);
      return response.data as Map<String, dynamic>;
    } catch (e) {
      _throwError(e);
    }
  }

  Future<Map<String, dynamic>> put(String path, {dynamic data}) async {
    try {
      final response = await _dio.put(path, data: data);
      return response.data as Map<String, dynamic>;
    } catch (e) {
      _throwError(e);
    }
  }

  Future<Map<String, dynamic>> delete(String path) async {
    try {
      final response = await _dio.delete(path);
      return response.data as Map<String, dynamic>;
    } catch (e) {
      _throwError(e);
    }
  }

  Never _throwError(dynamic e) {
    if (e is DioException && e.error is ApiException) {
      throw e.error as ApiException;
    }
    throw ApiException('An unexpected error occurred: $e');
  }
}
