class AuthResponseModel {
  final String token;
  final int userId;
  final String name;
  final String role;

  const AuthResponseModel({
    required this.token,
    required this.userId,
    required this.name,
    required this.role,
  });

  factory AuthResponseModel.fromJson(Map<String, dynamic> json) {
    return AuthResponseModel(
      token: json['token'] as String,
      userId: json['userId'] as int,
      name: json['name'] as String,
      role: json['role'] as String,
    );
  }
}
