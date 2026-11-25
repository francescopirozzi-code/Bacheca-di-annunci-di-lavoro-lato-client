import 'package:flutter_test/flutter_test.dart';
import 'package:bacheca_lavoro_client/main.dart';

void main() {
  testWidgets('Avvio Bacheca Lavoro smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const BachecaLavoroApp());
    expect(find.text('Bacheca Lavoro'), findsOneWidget);
  });
}