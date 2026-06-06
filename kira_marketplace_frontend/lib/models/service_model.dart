import 'package:flutter/foundation.dart';

import '../core/utils/json_helpers.dart';
import 'professional_model.dart';

@immutable
class ServiceModel {
  final int? id;
  final ProfessionalModel? professional;
  final int professionalId;
  final String name;
  final String description;
  final double price;
  final int durationMinutes;
  final bool active;
  final DateTime? createdAt;

  const ServiceModel({
    this.id,
    this.professional,
    required this.professionalId,
    required this.name,
    required this.description,
    required this.price,
    required this.durationMinutes,
    this.active = true,
    this.createdAt,
  });

  factory ServiceModel.fromJson(Map<String, dynamic> json) {
    final professionalJson = asMap(json['professional']);
    return ServiceModel(
      id: asInt(json['id']),
      professional: professionalJson == null
          ? null
          : ProfessionalModel.fromJson(professionalJson),
      professionalId:
          asInt(json['professionalId']) ?? asInt(professionalJson?['id']) ?? 0,
      name: asString(json['name']) ?? '',
      description: asString(json['description']) ?? '',
      price: asDouble(json['price']) ?? 0,
      durationMinutes: asInt(json['durationMinutes']) ?? 0,
      active: json['active'] is bool ? json['active'] as bool : true,
      createdAt: asDateTime(json['createdAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'professional': {'id': professionalId},
      'name': name,
      'description': description,
      'price': price,
      'durationMinutes': durationMinutes,
      'active': active,
      if (createdAt != null) 'createdAt': createdAt!.toIso8601String(),
    };
  }
}
