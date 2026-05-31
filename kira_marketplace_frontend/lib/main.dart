import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'pages/register_choice_page.dart';
import 'providers/auth_provider.dart';
import 'services/auth_service.dart';

void main() {
  runApp(const KiraApp());
}

class KiraApp extends StatelessWidget {
  const KiraApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => AuthProvider(
            authService: AuthService(),
          ),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Kira',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF0F766E)),
          useMaterial3: true,
        ),
        home: const RegisterChoicePage(),
      ),
    );
  }
}
