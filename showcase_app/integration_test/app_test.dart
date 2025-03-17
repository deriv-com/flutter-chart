import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:showcase_app/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('end-to-end test', () {
    testWidgets('Navigate through all chart examples', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Verify that we're on the home screen
      expect(find.text('Deriv Chart Showcase'), findsOneWidget);

      // Find all feature cards
      final featureCards = find.byType(Card);
      final featureCount = tester.widgetList(featureCards).length;

      // Navigate to each feature screen and back
      for (int i = 0; i < featureCount; i++) {
        // Find the current card and tap it
        final card = find.byType(Card).at(i);
        await tester.tap(card);
        await tester.pumpAndSettle();

        // Verify we're on a chart screen (all have a chart controller)
        expect(find.byType(AppBar), findsOneWidget);
        
        // Interact with some controls if available
        final switches = find.byType(Switch);
        if (switches.evaluate().isNotEmpty) {
          await tester.tap(switches.first);
          await tester.pumpAndSettle();
        }

        // Go back to the home screen
        await tester.tap(find.byType(BackButton));
        await tester.pumpAndSettle();

        // Verify we're back on the home screen
        expect(find.text('Deriv Chart Showcase'), findsOneWidget);
      }
    });
  });
}

// Note: To run this integration test, you would need to add the integration_test
// package to your pubspec.yaml and configure your app for integration testing.
// This is just a template to demonstrate how integration tests could be structured.
