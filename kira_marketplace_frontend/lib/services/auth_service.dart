import 'package:dio/dio.dart';

import '../core/constants/api_constants.dart';
import '../models/auth_response_model.dart';

class AuthService {
  final Dio _dio;

  AuthService({Dio? dio})
      : _dio = dio ??
            Dio(
              BaseOptions(
                baseUrl: ApiConstants.baseUrl,
                connectTimeout: const Duration(seconds: 20),
                receiveTimeout: const Duration(seconds: 20),
              ),
            );

  Future<AuthResponseModel> register(Map<String, dynamic> body) async {
    try {
      final response = await _dio.post(
        ApiConstants.register,
        data: body,
        options: Options(contentType: Headers.jsonContentType),
      );
      return AuthResponseModel.fromJson(
        Map<String, dynamic>.from(response.data as Map),
      );
    } on DioException catch (error) {
      final data = error.response?.data;
      if (data is Map && data['message'] is String) {
        throw Exception(data['message']);
      }
      rethrow;
    }
  }
}
