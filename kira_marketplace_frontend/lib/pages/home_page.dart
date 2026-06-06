import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import 'client_home_page.dart';
import 'professional_home_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final role = authProvider.authResponse?.role;

    // Redireciona para a página apropriada baseado na role
    if (role == 'ROLE_CLIENT') {
      return const ClientHomePage();
    } else if (role == 'ROLE_PROFESSIONAL') {
      return const ProfessionalHomePage();
    }

    // Página padrão se a role não for reconhecida
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kira'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.check_circle,
                size: 64,
                color: Color(0xFF0F766E),
              ),
              const SizedBox(height: 16),
              Text(
                'Bem-vindo ao Kira!',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF0F766E),
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Em breve mais funcionalidades.',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Colors.grey[600],
                    ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
