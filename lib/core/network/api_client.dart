import 'dart:developer' as developer;
import 'package:dio/dio.dart';
import '../error/failures.dart';

/// ApiClient wraps Dio with interceptors, timeouts, and Clean Architecture failure mapping.
class ApiClient {
  final Dio dio;

  ApiClient({Dio? dioClient})
      : dio = dioClient ??
            Dio(
              BaseOptions(
                baseUrl: 'https://api.nestify-proptech.io/v1',
                connectTimeout: const Duration(seconds: 10),
                receiveTimeout: const Duration(seconds: 10),
                headers: {
                  'Content-Type': 'application/json',
                  'Accept': 'application/json',
                  'X-Client-Platform': 'Nestify-Flutter',
                },
              ),
            ) {
    _initInterceptors();
  }

  void _initInterceptors() {
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          developer.log(
            '--> ${options.method} ${options.uri}',
            name: 'Nestify.ApiClient',
          );
          return handler.next(options);
        },
        onResponse: (response, handler) {
          developer.log(
            '<-- ${response.statusCode} ${response.requestOptions.uri}',
            name: 'Nestify.ApiClient',
          );
          return handler.next(response);
        },
        onError: (DioException e, handler) {
          developer.log(
            '<-- ERROR ${e.response?.statusCode} ${e.message}',
            name: 'Nestify.ApiClient',
            error: e,
          );
          return handler.next(e);
        },
      ),
    );
  }

  Failure handleDioError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.connectionError:
        return const NetworkFailure(
          message: 'Connection timed out. Please check your internet connectivity.',
        );
      case DioExceptionType.badResponse:
        final code = error.response?.statusCode;
        final msg = error.response?.data is Map
            ? error.response?.data['message'] ?? 'Server error occurred'
            : 'Server responded with status $code';
        return ServerFailure(message: msg.toString(), statusCode: code);
      case DioExceptionType.cancel:
        return const NetworkFailure(message: 'Request was cancelled.');
      default:
        return ServerFailure(
          message: error.message ?? 'An unexpected network error occurred.',
        );
    }
  }

  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await dio.get<T>(
        path,
        queryParameters: queryParameters,
        options: options,
      );
    } on DioException catch (e) {
      throw handleDioError(e);
    }
  }

  Future<Response<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await dio.post<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
    } on DioException catch (e) {
      throw handleDioError(e);
    }
  }
}
