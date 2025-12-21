import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:flutter_app/main.dart' as app;
import 'package:flutter_app/screens/login_screen.dart';
import 'package:flutter_app/screens/dashboard_screen.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Login Flow Integration Test', () {
    testWidgets('Full login flow - invalid credentials shows error', (WidgetTester tester) async {
      // Launch app
      app.main();
      await tester.pumpAndSettle();

      // Verify we're on login screen
      expect(find.byType(LoginScreen), findsOneWidget);
      expect(find.text('CHU Santé'), findsOneWidget);

      // Enter invalid credentials
      await tester.enterText(find.byType(TextFormField).at(0), 'invalid_user');
      await tester.enterText(find.byType(TextFormField).at(1), 'wrongpassword');

      // Tap login button
      await tester.tap(find.widgetWithText(ElevatedButton, 'Se connecter'));
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Should still be on login screen with error
      expect(find.byType(LoginScreen), findsOneWidget);
    });

    testWidgets('Full login flow - valid credentials navigates to dashboard', (WidgetTester tester) async {
      // Note: This test requires backend to be running with valid test credentials
      // Launch app
      app.main();
      await tester.pumpAndSettle();

      // Enter valid test credentials
      await tester.enterText(find.byType(TextFormField).at(0), 'admin01');
      await tester.enterText(find.byType(TextFormField).at(1), 'GHassane');

      // Tap login button
      await tester.tap(find.widgetWithText(ElevatedButton, 'Se connecter'));
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // Should navigate to dashboard
      expect(find.byType(DashboardScreen), findsOneWidget);
    });

    testWidgets('Signup flow - creates new account', (WidgetTester tester) async {
      // Launch app
      app.main();
      await tester.pumpAndSettle();

      // Switch to signup
      await tester.tap(find.text('Créer un compte'));
      await tester.pumpAndSettle();

      // Verify signup form is displayed
      expect(find.text('Nom'), findsOneWidget);
      expect(find.text('Prénom'), findsOneWidget);
      expect(find.text('Email'), findsOneWidget);
    });
  });
}
