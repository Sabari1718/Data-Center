import 'package:dio/dio.dart';
import '../errors/app_failure.dart';

class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final dynamic data;

  ApiException({
    required this.message,
    this.statusCode,
    this.data,
  });

  factory ApiException.fromDioException(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
        return ApiException(
          message: 'Connection timed out. Please check your internet connection.',
          statusCode: error.response?.statusCode,
        );
      case DioExceptionType.sendTimeout:
        return ApiException(
          message: 'Request send timeout. Please try again.',
          statusCode: error.response?.statusCode,
        );
      case DioExceptionType.receiveTimeout:
        return ApiException(
          message: 'Response receive timeout. Server took too long to respond.',
          statusCode: error.response?.statusCode,
        );
      case DioExceptionType.badResponse:
        final statusCode = error.response?.statusCode;
        final responseData = error.response?.data;
        String message = 'An unexpected server error occurred ($statusCode).';

        if (responseData is Map && responseData.containsKey('message')) {
          message = responseData['message'].toString();
        } else if (responseData is String && responseData.isNotEmpty) {
          message = responseData;
        } else {
          switch (statusCode) {
            case 400:
              message = 'Bad request. Please verify your input.';
              break;
            case 401:
              message = 'Authentication expired or invalid. Please login again.';
              break;
            case 403:
              message = 'Access forbidden. You do not have permissions for this resource.';
              break;
            case 404:
              message = 'Requested resource not found.';
              break;
            case 409:
              message = 'Conflict. This entity already exists or is in an invalid state.';
              break;
            case 500:
              message = 'Internal server error. Please try again later.';
              break;
            case 503:
              message = 'Service temporarily unavailable. Maintenance may be in progress.';
              break;
          }
        }

        return ApiException(
          message: message,
          statusCode: statusCode,
          data: responseData,
        );

      case DioExceptionType.cancel:
        return ApiException(message: 'Request was cancelled.');
      case DioExceptionType.connectionError:
        return ApiException(
          message: 'Unable to connect to server. Check your network connection.',
        );
      case DioExceptionType.unknown:
      default:
        return ApiException(
          message: error.message?.isNotEmpty == true
              ? error.message!
              : 'An unexpected network error occurred.',
        );
    }
  }

  AppFailure toAppFailure() {
    if (statusCode == 401 || statusCode == 403) {
      return AuthFailure(message, statusCode: statusCode);
    }
    if (statusCode != null && statusCode! >= 500) {
      return ServerFailure(message, statusCode: statusCode);
    }
    return NetworkFailure(message, statusCode: statusCode);
  }

  @override
  String toString() => message;
}
