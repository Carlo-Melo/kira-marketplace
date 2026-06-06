import 'package:dio/dio.dart';

import '../core/constants/api_constants.dart';
import '../models/service_model.dart';

class CatalogService {
  final Dio _dio;

  CatalogService({Dio? dio})
      : _dio = dio ??
            Dio(
              BaseOptions(
                baseUrl: ApiConstants.baseUrl,
                connectTimeout: const Duration(seconds: 20),
                receiveTimeout: const Duration(seconds: 20),
              ),
            );

  Future<List<ServiceModel>> findAll() async {
    try {
      final response = await _dio.get(ApiConstants.services);
      return (response.data as List)
          .map((item) => ServiceModel.fromJson(Map<String, dynamic>.from(item as Map)))
          .toList();
    } on DioException catch (error) {
      _handleError(error);
      rethrow;
    }
  }

  Future<ServiceModel> findById(int id) async {
    try {
      final response = await _dio.get('${ApiConstants.services}/$id');
      return ServiceModel.fromJson(Map<String, dynamic>.from(response.data as Map));
    } on DioException catch (error) {
      _handleError(error);
      rethrow;
    }
  }

  Future<List<ServiceModel>> findByProfessionalId(int professionalId) async {
    try {
      final response = await _dio.get(
        ApiConstants.services,
        queryParameters: {'professionalId': professionalId},
      );
      return (response.data as List)
          .map((item) => ServiceModel.fromJson(Map<String, dynamic>.from(item as Map)))
          .toList();
    } on DioException catch (error) {
      _handleError(error);
      rethrow;
    }
  }

  Future<List<ServiceModel>> search(String query) async {
    try {
      final response = await _dio.get(
        ApiConstants.services,
        queryParameters: {'q': query},
      );
      return (response.data as List)
          .map((item) => ServiceModel.fromJson(Map<String, dynamic>.from(item as Map)))
          .toList();
    } on DioException catch (error) {
      _handleError(error);
      rethrow;
    }
  }

  Future<ServiceModel> create(ServiceModel service) async {
    try {
      final response = await _dio.post(
        ApiConstants.services,
        data: service.toJson(),
        options: Options(contentType: Headers.jsonContentType),
      );
      return ServiceModel.fromJson(Map<String, dynamic>.from(response.data as Map));
    } on DioException catch (error) {
      _handleError(error);
      rethrow;
    }
  }

  Future<ServiceModel> update(int id, ServiceModel service) async {
    try {
      final response = await _dio.put(
        '${ApiConstants.services}/$id',
        data: service.toJson(),
        options: Options(contentType: Headers.jsonContentType),
      );
      return ServiceModel.fromJson(Map<String, dynamic>.from(response.data as Map));
    } on DioException catch (error) {
      _handleError(error);
      rethrow;
    }
  }

  Future<void> delete(int id) async {
    try {
      await _dio.delete('${ApiConstants.services}/$id');
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
