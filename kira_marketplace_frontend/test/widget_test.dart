import 'package:flutter_test/flutter_test.dart';
import 'package:kira_marketplace_frontend/main.dart';

void main() {
  testWidgets('shows login screen', (WidgetTester tester) async {
    await tester.pumpWidget(const KiraApp());

    expect(find.text('Bem-vindo ao Kira'), findsOneWidget);
    expect(find.text('Entrar'), findsOneWidget);
    expect(find.text('Email'), findsOneWidget);
    expect(find.text('Senha'), findsOneWidget);
  });
}
