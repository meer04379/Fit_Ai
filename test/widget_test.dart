import 'package:flutter_test/flutter_test.dart';
import 'package:fit_ai/main.dart';

void main() {
  testWidgets('FitAI App launches and shows splash/brand title', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const FitAIApp());

    // Verify that FitAI brand text is present
    expect(find.text('Fit'), findsOneWidget);
    expect(find.text('AI'), findsOneWidget);
    expect(find.text('Better Food. Better You.'), findsOneWidget);
  });
}
