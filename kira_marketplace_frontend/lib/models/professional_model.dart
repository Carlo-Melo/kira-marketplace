import 'package:flutter/foundation.dart';

import '../core/utils/json_helpers.dart';
import 'user_model.dart';

@immutable
class ProfessionalModel {
  final int? id;
  final UserModel? user;
  final int? userId;
  final String documentType;
  final String documentNumber;
  final String bio;
  final String city;
  final String address;
  final double? latitude;
  final double? longitude;
  final double? rating;
  final int? totalReviews;
  final DateTime? createdAt;

  const ProfessionalModel({
    this.id,
    this.user,
    this.userId,
    required this.documentType,
    required this.documentNumber,
    required this.bio,
    required this.city,
    required this.address,
    this.latitude,
    this.longitude,
    this.rating,
    this.totalReviews,
    this.createdAt,
  });

  int? get resolvedUserId => userId ?? user?.id;

  factory ProfessionalModel.fromJson(Map<String, dynamic> json) {
    final userJson = asMap(json['user']);
    return ProfessionalModel(
      id: asInt(json['id']),
      user: userJson == null ? null : UserModel.fromJson(userJson),
      userId: asInt(json['userId']) ?? asInt(userJson?['id']),
      documentType: asString(json['documentType']) ?? '',
      documentNumber: asString(json['documentNumber']) ?? '',
      bio: asString(json['bio']) ?? '',
      city: asString(json['city']) ?? '',
      address: asString(json['address']) ?? '',
      latitude: asDouble(json['latitude']),
      longitude: asDouble(json['longitude']),
      rating: asDouble(json['rating']),
      totalReviews: asInt(json['totalReviews']),
      createdAt: asDateTime(json['createdAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'user': {'id': resolvedUserId},
      'documentType': documentType,
      'documentNumber': documentNumber,
      'bio': bio,
      'city': city,
      'address': address,
      if (latitude != null) 'latitude': latitude,
      if (longitude != null) 'longitude': longitude,
      if (rating != null) 'rating': rating,
      if (totalReviews != null) 'totalReviews': totalReviews,
      if (createdAt != null) 'createdAt': createdAt!.toIso8601String(),
    };
  }
}
