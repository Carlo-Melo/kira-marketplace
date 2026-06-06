import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'pages/client_home_page.dart';
import 'pages/client_register_page.dart';
import 'pages/home_page.dart';
import 'pages/login_page.dart';
import 'pages/professional_home_page.dart';
import 'pages/professional_register_page.dart';
import 'pages/register_choice_page.dart';
import 'core/theme/app_theme.dart';
import 'providers/auth_provider.dart';
import 'providers/booking_provider.dart';
import 'providers/catalog_provider.dart';
import 'providers/payment_provider.dart';
import 'providers/professional_provider.dart';
import 'providers/review_provider.dart';
import 'services/auth_service.dart';
import 'services/booking_service.dart';
import 'services/catalog_service.dart';
import 'services/payment_service.dart';
import 'services/professional_service.dart';
import 'services/review_service.dart';

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
          create: (_) => AuthProvider(authService: AuthService()),
        ),
        ChangeNotifierProvider(
          create: (_) => CatalogProvider(catalogService: CatalogService()),
        ),
        ChangeNotifierProvider(
          create: (_) => BookingProvider(bookingService: BookingService()),
        ),
        ChangeNotifierProvider(
          create: (_) =>
              ProfessionalProvider(professionalService: ProfessionalService()),
        ),
        ChangeNotifierProvider(
          create: (_) => PaymentProvider(paymentService: PaymentService()),
        ),
        ChangeNotifierProvider(
          create: (_) => ReviewProvider(reviewService: ReviewService()),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Kira',
        theme: AppTheme.light(),
        home: const LoginPage(),
        routes: {
          '/login': (_) => const LoginPage(),
          '/register-choice': (_) => const RegisterChoicePage(),
          '/register-client': (_) => const ClientRegisterPage(),
          '/register-professional': (_) => const ProfessionalRegisterPage(),
          '/home': (_) => const HomePage(),
          '/client-home': (_) => const ClientHomePage(),
          '/professional-home': (_) => const ProfessionalHomePage(),
        },
      ),
    );
  }
}
