import 'package:flutter/foundation.dart';

import '../core/utils/json_helpers.dart';
import 'professional_model.dart';
import 'service_model.dart';
import 'user_model.dart';

@immutable
class BookingModel {
  final int? id;
  final UserModel? client;
  final ProfessionalModel? professional;
  final ServiceModel? service;
  final int clientId;
  final int professionalId;
  final int serviceId;
  final DateTime? bookingDate;
  final String status;
  final double? price;
  final DateTime? createdAt;

  const BookingModel({
    this.id,
    this.client,
    this.professional,
    this.service,
    required this.clientId,
    required this.professionalId,
    required this.serviceId,
    this.bookingDate,
    required this.status,
    this.price,
    this.createdAt,
  });

  factory BookingModel.fromJson(Map<String, dynamic> json) {
    final clientJson = asMap(json['client']);
    final professionalJson = asMap(json['professional']);
    final serviceJson = asMap(json['service']);
    return BookingModel(
      id: asInt(json['id']),
      client: clientJson == null ? null : UserModel.fromJson(clientJson),
      professional: professionalJson == null
          ? null
          : ProfessionalModel.fromJson(professionalJson),
      service: serviceJson == null ? null : ServiceModel.fromJson(serviceJson),
      clientId: asInt(json['clientId']) ?? asInt(clientJson?['id']) ?? 0,
      professionalId:
          asInt(json['professionalId']) ?? asInt(professionalJson?['id']) ?? 0,
      serviceId: asInt(json['serviceId']) ?? asInt(serviceJson?['id']) ?? 0,
      bookingDate: asDateTime(json['bookingDate'] ?? json['scheduledDate']),
      status: asString(json['status']) ?? '',
      price: asDouble(json['price']),
      createdAt: asDateTime(json['createdAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'client': {'id': clientId},
      'professional': {'id': professionalId},
      'service': {'id': serviceId},
      if (bookingDate != null) 'bookingDate': bookingDate!.toIso8601String(),
      'status': status,
      if (price != null) 'price': price,
      if (createdAt != null) 'createdAt': createdAt!.toIso8601String(),
    };
  }
}
