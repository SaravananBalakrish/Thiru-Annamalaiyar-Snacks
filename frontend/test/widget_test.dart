import 'package:flutter_test/flutter_test.dart';
import 'package:thiru_annamalaiyar_snacks/main.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const AnnamalaiyarApp());

    // Verify that the login page brand name is present.
    expect(find.text('ANNAMALAIYAR'), findsOneWidget);
    
    // Verify welcome text
    expect(find.text('Welcome'), findsOneWidget);

    // Verify skip button exists to jump to home
    expect(find.text('Skip'), findsOneWidget);
  });
}
