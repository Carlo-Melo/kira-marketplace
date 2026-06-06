import 'package:dio/dio.dart';

import '../core/constants/api_constants.dart';
import '../models/review_model.dart';

class ReviewService {
  final Dio _dio;

  ReviewService({Dio? dio})
      : _dio = dio ??
            Dio(
              BaseOptions(
                baseUrl: ApiConstants.baseUrl,
                connectTimeout: const Duration(seconds: 20),
                receiveTimeout: const Duration(seconds: 20),
              ),
            );

  Future<List<ReviewModel>> findAll() async {
    try {
      final response = await _dio.get(ApiConstants.reviews);
      return (response.data as List)
          .map((item) => ReviewModel.fromJson(Map<String, dynamic>.from(item as Map)))
          .toList();
    } on DioException catch (error) {
      _handleError(error);
      rethrow;
    }
  }

  Future<ReviewModel> findById(int id) async {
    try {
      final response = await _dio.get('${ApiConstants.reviews}/$id');
      return ReviewModel.fromJson(Map<String, dynamic>.from(response.data as Map));
    } on DioException catch (error) {
      _handleError(error);
      rethrow;
    }
  }

  Future<List<ReviewModel>> findByProfessionalId(int professionalId) async {
    try {
      final response = await _dio.get(
        ApiConstants.reviews,
        queryParameters: {'professionalId': professionalId},
      );
      return (response.data as List)
          .map((item) => ReviewModel.fromJson(Map<String, dynamic>.from(item as Map)))
          .toList();
    } on DioException catch (error) {
      _handleError(error);
      rethrow;
    }
  }

  Future<ReviewModel> create(ReviewModel review) async {
    try {
      final response = await _dio.post(
        ApiConstants.reviews,
        data: review.toJson(),
        options: Options(contentType: Headers.jsonContentType),
      );
      return ReviewModel.fromJson(Map<String, dynamic>.from(response.data as Map));
    } on DioException catch (error) {
      _handleError(error);
      rethrow;
    }
  }

  Future<ReviewModel> update(int id, ReviewModel review) async {
    try {
      final response = await _dio.put(
        '${ApiConstants.reviews}/$id',
        data: review.toJson(),
        options: Options(contentType: Headers.jsonContentType),
      );
      return ReviewModel.fromJson(Map<String, dynamic>.from(response.data as Map));
    } on DioException catch (error) {
      _handleError(error);
      rethrow;
    }
  }

  Future<void> delete(int id) async {
    try {
      await _dio.delete('${ApiConstants.reviews}/$id');
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
