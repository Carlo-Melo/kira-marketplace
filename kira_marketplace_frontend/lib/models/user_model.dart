import 'package:flutter/foundation.dart';

import '../core/utils/json_helpers.dart';

@immutable
class UserModel {
  final int? id;
  final String name;
  final String email;
  final String password;
  final String cpf;
  final String phone;
  final String role;
  final DateTime? createdAt;

  const UserModel({
    this.id,
    required this.name,
    required this.email,
    required this.password,
    required this.cpf,
    required this.phone,
    required this.role,
    this.createdAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: asInt(json['id']),
      name: asString(json['name']) ?? '',
      email: asString(json['email']) ?? '',
      password: asString(json['password']) ?? '',
      cpf: asString(json['cpf']) ?? '',
      phone: asString(json['phone']) ?? '',
      role: asString(json['role']) ?? '',
      createdAt: asDateTime(json['createdAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'name': name,
      'email': email,
      'password': password,
      'cpf': cpf,
      'phone': phone,
      'role': role,
      if (createdAt != null) 'createdAt': createdAt!.toIso8601String(),
    };
  }
}
