import 'package:flutter_test/flutter_test.dart';
import 'package:kira_marketplace_frontend/main.dart';

void main() {
  testWidgets('shows register choice screen', (WidgetTester tester) async {
    await tester.pumpWidget(const KiraApp());

    expect(find.text('Kira'), findsOneWidget);
    expect(find.text('Como você quer usar o Kira?'), findsOneWidget);
    expect(find.text('Sou cliente'), findsOneWidget);
    expect(find.text('Sou profissional'), findsOneWidget);
  });
}
