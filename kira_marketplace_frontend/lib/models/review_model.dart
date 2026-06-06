import 'package:flutter/foundation.dart';

import '../core/utils/json_helpers.dart';
import 'booking_model.dart';
import 'professional_model.dart';
import 'user_model.dart';

@immutable
class ReviewModel {
  final int? id;
  final BookingModel? booking;
  final UserModel? client;
  final ProfessionalModel? professional;
  final int bookingId;
  final int clientId;
  final int professionalId;
  final int rating;
  final String comment;
  final DateTime? createdAt;

  const ReviewModel({
    this.id,
    this.booking,
    this.client,
    this.professional,
    required this.bookingId,
    required this.clientId,
    required this.professionalId,
    required this.rating,
    required this.comment,
    this.createdAt,
  });

  factory ReviewModel.fromJson(Map<String, dynamic> json) {
    final bookingJson = asMap(json['booking']);
    final clientJson = asMap(json['client']);
    final professionalJson = asMap(json['professional']);
    return ReviewModel(
      id: asInt(json['id']),
      booking: bookingJson == null ? null : BookingModel.fromJson(bookingJson),
      client: clientJson == null ? null : UserModel.fromJson(clientJson),
      professional: professionalJson == null
          ? null
          : ProfessionalModel.fromJson(professionalJson),
      bookingId: asInt(json['bookingId']) ?? asInt(bookingJson?['id']) ?? 0,
      clientId: asInt(json['clientId']) ?? asInt(clientJson?['id']) ?? 0,
      professionalId:
          asInt(json['professionalId']) ?? asInt(professionalJson?['id']) ?? 0,
      rating: asInt(json['rating']) ?? 0,
      comment: asString(json['comment']) ?? '',
      createdAt: asDateTime(json['createdAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'booking': {'id': bookingId},
      'rating': rating,
      'comment': comment,
      if (createdAt != null) 'createdAt': createdAt!.toIso8601String(),
    };
  }
}
