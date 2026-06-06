import 'package:flutter/foundation.dart';

import '../core/utils/json_helpers.dart';
import 'booking_model.dart';

@immutable
class PaymentModel {
  final int? id;
  final BookingModel? booking;
  final int bookingId;
  final double amount;
  final String method;
  final String status;
  final String? transactionId;
  final DateTime? createdAt;

  const PaymentModel({
    this.id,
    this.booking,
    required this.bookingId,
    required this.amount,
    required this.method,
    required this.status,
    this.transactionId,
    this.createdAt,
  });

  factory PaymentModel.fromJson(Map<String, dynamic> json) {
    final bookingJson = asMap(json['booking']);
    return PaymentModel(
      id: asInt(json['id']),
      booking: bookingJson == null ? null : BookingModel.fromJson(bookingJson),
      bookingId: asInt(json['bookingId']) ?? asInt(bookingJson?['id']) ?? 0,
      amount: asDouble(json['amount']) ?? 0,
      method: asString(json['method'] ?? json['paymentMethod']) ?? '',
      status: asString(json['status']) ?? '',
      transactionId: asString(json['transactionId']),
      createdAt: asDateTime(json['createdAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'booking': {'id': bookingId},
      'amount': amount,
      'method': method,
      'status': status,
      if (transactionId != null) 'transactionId': transactionId,
      if (createdAt != null) 'createdAt': createdAt!.toIso8601String(),
    };
  }
}
