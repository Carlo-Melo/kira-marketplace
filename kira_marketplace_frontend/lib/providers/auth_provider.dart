import 'package:flutter/foundation.dart';

import '../models/auth_response_model.dart';
import '../services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService authService;

  AuthProvider({required this.authService});

  bool _isLoading = false;
  String? _errorMessage;
  AuthResponseModel? _authResponse;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  AuthResponseModel? get authResponse => _authResponse;

  Future<void> registerClient({
    required String name,
    required String email,
    required String password,
    required String cpf,
    required String phone,
  }) async {
    await _register({
      'name': name,
      'email': email,
      'password': password,
      'cpf': cpf,
      'phone': phone,
      'role': 'ROLE_CLIENT',
    });
  }

  Future<void> registerProfessional({
    required String name,
    required String email,
    required String password,
    required String cpf,
    required String phone,
    required String documentType,
    required String documentNumber,
    required String bio,
    required String city,
    required String address,
    double? latitude,
    double? longitude,
  }) async {
    final body = <String, dynamic>{
      'name': name,
      'email': email,
      'password': password,
      'cpf': cpf,
      'phone': phone,
      'role': 'ROLE_PROFESSIONAL',
      'documentType': documentType,
      'documentNumber': documentNumber,
      'bio': bio,
      'city': city,
      'address': address,
    };
    if (latitude != null) body['latitude'] = latitude;
    if (longitude != null) body['longitude'] = longitude;

    await _register(body);
  }

  Future<void> _register(Map<String, dynamic> body) async {
    _isLoading = true;
    _errorMessage = null;
    _authResponse = null;
    notifyListeners();

    try {
      _authResponse = await authService.register(body);
    } catch (error) {
      _errorMessage = _formatError(error);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearState() {
    _isLoading = false;
    _errorMessage = null;
    _authResponse = null;
    notifyListeners();
  }

  String _formatError(Object error) {
    final message = error.toString();
    if (message.startsWith('Exception: ')) {
      return message.substring('Exception: '.length);
    }
    return 'Não foi possível realizar o cadastro.';
  }
}
