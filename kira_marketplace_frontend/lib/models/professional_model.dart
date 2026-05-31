import 'package:flutter/foundation.dart';

@immutable
class ProfessionalModel {
  final int? id;
  final int userId;
  final String documentType;
  final String documentNumber;
  final String bio;
  final String city;
  final String address;

  const ProfessionalModel({
    this.id,
    required this.userId,
    required this.documentType,
    required this.documentNumber,
    required this.bio,
    required this.city,
    required this.address,
  });

  Map<String, dynamic> toJson() {
    return {
      'user': {'id': userId},
      'documentType': documentType,
      'documentNumber': documentNumber,
      'bio': bio,
      'city': city,
      'address': address,
    };
  }
}
