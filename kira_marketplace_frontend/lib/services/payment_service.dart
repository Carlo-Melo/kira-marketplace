import 'package:dio/dio.dart';

import '../core/constants/api_constants.dart';
import '../models/payment_model.dart';

class PaymentService {
  final Dio _dio;

  PaymentService({Dio? dio})
    : _dio =
          dio ??
          Dio(
            BaseOptions(
              baseUrl: ApiConstants.baseUrl,
              connectTimeout: const Duration(seconds: 20),
              receiveTimeout: const Duration(seconds: 20),
            ),
          );

  Future<List<PaymentModel>> findAll() async {
    try {
      final response = await _dio.get(ApiConstants.payments);
      return (response.data as List)
          .map(
            (item) =>
                PaymentModel.fromJson(Map<String, dynamic>.from(item as Map)),
          )
          .toList();
    } on DioException catch (error) {
      _handleError(error);
      rethrow;
    }
  }

  Future<PaymentModel> findById(int id) async {
    try {
      final response = await _dio.get('${ApiConstants.payments}/$id');
      return PaymentModel.fromJson(
        Map<String, dynamic>.from(response.data as Map),
      );
    } on DioException catch (error) {
      _handleError(error);
      rethrow;
    }
  }

  Future<PaymentModel> findByBookingId(int bookingId) async {
    try {
      final response = await _dio.get(
        ApiConstants.payments,
        queryParameters: {'bookingId': bookingId},
      );
      final data = response.data;
      if (data is List && data.isNotEmpty) {
        return PaymentModel.fromJson(
          Map<String, dynamic>.from(data.first as Map),
        );
      }
      if (data is Map) {
        return PaymentModel.fromJson(Map<String, dynamic>.from(data));
      }
      throw Exception('Payment not found for booking: $bookingId');
    } on DioException catch (error) {
      _handleError(error);
      rethrow;
    }
  }

  Future<PaymentModel> create(PaymentModel payment) async {
    try {
      final response = await _dio.post(
        ApiConstants.payments,
        data: payment.toJson(),
        options: Options(contentType: Headers.jsonContentType),
      );
      return PaymentModel.fromJson(
        Map<String, dynamic>.from(response.data as Map),
      );
    } on DioException catch (error) {
      _handleError(error);
      rethrow;
    }
  }

  Future<PaymentModel> update(int id, PaymentModel payment) async {
    try {
      final response = await _dio.put(
        '${ApiConstants.payments}/$id',
        data: payment.toJson(),
        options: Options(contentType: Headers.jsonContentType),
      );
      return PaymentModel.fromJson(
        Map<String, dynamic>.from(response.data as Map),
      );
    } on DioException catch (error) {
      _handleError(error);
      rethrow;
    }
  }

  Future<void> delete(int id) async {
    try {
      await _dio.delete('${ApiConstants.payments}/$id');
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
