class ApiConstants {
  ApiConstants._();

  // Para Android emulator use 10.0.2.2 no lugar de localhost.
  static const String baseUrl = 'http://localhost:8085';

  static const String register = '/auth/register';
  static const String login = '/auth/login';
  static const String users = '/users';
  static const String professionals = '/professionals';
}
