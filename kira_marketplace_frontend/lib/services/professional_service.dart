import 'package:dio/dio.dart';

import '../core/constants/api_constants.dart';
import '../models/professional_model.dart';

class ProfessionalService {
  final Dio _dio;

  ProfessionalService({Dio? dio})
      : _dio = dio ??
            Dio(
              BaseOptions(
                baseUrl: ApiConstants.baseUrl,
                connectTimeout: const Duration(seconds: 20),
                receiveTimeout: const Duration(seconds: 20),
              ),
            );

  Future<List<ProfessionalModel>> findAll() async {
    try {
      final response = await _dio.get(ApiConstants.professionals);
      return (response.data as List)
          .map((item) => ProfessionalModel.fromJson(Map<String, dynamic>.from(item as Map)))
          .toList();
    } on DioException catch (error) {
      _handleError(error);
      rethrow;
    }
  }

  Future<ProfessionalModel> findById(int id) async {
    try {
      final response = await _dio.get('${ApiConstants.professionals}/$id');
      return ProfessionalModel.fromJson(Map<String, dynamic>.from(response.data as Map));
    } on DioException catch (error) {
      _handleError(error);
      rethrow;
    }
  }

  Future<List<ProfessionalModel>> findByCity(String city) async {
    try {
      final response = await _dio.get(
        ApiConstants.professionals,
        queryParameters: {'city': city},
      );
      return (response.data as List)
          .map((item) => ProfessionalModel.fromJson(Map<String, dynamic>.from(item as Map)))
          .toList();
    } on DioException catch (error) {
      _handleError(error);
      rethrow;
    }
  }

  Future<List<ProfessionalModel>> findByMinRating(double minRating) async {
    try {
      final response = await _dio.get(
        ApiConstants.professionals,
        queryParameters: {'minRating': minRating},
      );
      return (response.data as List)
          .map((item) => ProfessionalModel.fromJson(Map<String, dynamic>.from(item as Map)))
          .toList();
    } on DioException catch (error) {
      _handleError(error);
      rethrow;
    }
  }

  Future<ProfessionalModel> create(ProfessionalModel professional) async {
    try {
      final response = await _dio.post(
        ApiConstants.professionals,
        data: professional.toJson(),
        options: Options(contentType: Headers.jsonContentType),
      );
      return ProfessionalModel.fromJson(Map<String, dynamic>.from(response.data as Map));
    } on DioException catch (error) {
      _handleError(error);
      rethrow;
    }
  }

  Future<ProfessionalModel> update(int id, ProfessionalModel professional) async {
    try {
      final response = await _dio.put(
        '${ApiConstants.professionals}/$id',
        data: professional.toJson(),
        options: Options(contentType: Headers.jsonContentType),
      );
      return ProfessionalModel.fromJson(Map<String, dynamic>.from(response.data as Map));
    } on DioException catch (error) {
      _handleError(error);
      rethrow;
    }
  }

  Future<void> delete(int id) async {
    try {
      await _dio.delete('${ApiConstants.professionals}/$id');
    } on DioException catch (error) {
      _handleError(error);
      rethrow;
    }
  }

  void _handleError(DioException error) {
    final data = error.response?.data;
    if (data is Map && data['message'] is String) {
      throw Exception(data['message']);
    }
  }
}
