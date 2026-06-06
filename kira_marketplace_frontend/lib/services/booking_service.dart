import 'package:dio/dio.dart';

import '../core/constants/api_constants.dart';
import '../models/booking_model.dart';

class BookingService {
  final Dio _dio;

  BookingService({Dio? dio})
      : _dio = dio ??
            Dio(
              BaseOptions(
                baseUrl: ApiConstants.baseUrl,
                connectTimeout: const Duration(seconds: 20),
                receiveTimeout: const Duration(seconds: 20),
              ),
            );

  Future<List<BookingModel>> findAll() async {
    try {
      final response = await _dio.get(ApiConstants.bookings);
      return (response.data as List)
          .map((item) => BookingModel.fromJson(Map<String, dynamic>.from(item as Map)))
          .toList();
    } on DioException catch (error) {
      _handleError(error);
      rethrow;
    }
  }

  Future<BookingModel> findById(int id) async {
    try {
      final response = await _dio.get('${ApiConstants.bookings}/$id');
      return BookingModel.fromJson(Map<String, dynamic>.from(response.data as Map));
    } on DioException catch (error) {
      _handleError(error);
      rethrow;
    }
  }

  Future<List<BookingModel>> findByClientId(int clientId) async {
    try {
      final response = await _dio.get(
        ApiConstants.bookings,
        queryParameters: {'clientId': clientId},
      );
      return (response.data as List)
          .map((item) => BookingModel.fromJson(Map<String, dynamic>.from(item as Map)))
          .toList();
    } on DioException catch (error) {
      _handleError(error);
      rethrow;
    }
  }

  Future<List<BookingModel>> findByProfessionalId(int professionalId) async {
    try {
      final response = await _dio.get(
        ApiConstants.bookings,
        queryParameters: {'professionalId': professionalId},
      );
      return (response.data as List)
          .map((item) => BookingModel.fromJson(Map<String, dynamic>.from(item as Map)))
          .toList();
    } on DioException catch (error) {
      _handleError(error);
      rethrow;
    }
  }

  Future<BookingModel> create(BookingModel booking) async {
    try {
      final response = await _dio.post(
        ApiConstants.bookings,
        data: booking.toJson(),
        options: Options(contentType: Headers.jsonContentType),
      );
      return BookingModel.fromJson(Map<String, dynamic>.from(response.data as Map));
    } on DioException catch (error) {
      _handleError(error);
      rethrow;
    }
  }

  Future<BookingModel> update(int id, BookingModel booking) async {
    try {
      final response = await _dio.put(
        '${ApiConstants.bookings}/$id',
        data: booking.toJson(),
        options: Options(contentType: Headers.jsonContentType),
      );
      return BookingModel.fromJson(Map<String, dynamic>.from(response.data as Map));
    } on DioException catch (error) {
      _handleError(error);
      rethrow;
    }
  }

  Future<void> delete(int id) async {
    try {
      await _dio.delete('${ApiConstants.bookings}/$id');
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
