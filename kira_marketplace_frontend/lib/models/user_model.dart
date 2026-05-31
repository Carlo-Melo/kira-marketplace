import 'package:flutter/foundation.dart';

@immutable
class UserModel {
  final int? id;
  final String name;
  final String email;
  final String password;
  final String cpf;
  final String phone;
  final String role;

  const UserModel({
    this.id,
    required this.name,
    required this.email,
    required this.password,
    required this.cpf,
    required this.phone,
    required this.role,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'email': email,
      'password': password,
      'cpf': cpf,
      'phone': phone,
      'role': role,
    };
  }
}
