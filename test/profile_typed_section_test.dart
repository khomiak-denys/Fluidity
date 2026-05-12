import 'package:fluidity/l10n/app_localizations.dart';
import 'package:fluidity/screens/profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('ProfileScreen renders typed settings section', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: ProfileScreen(
          dailyGoal: 2200,
          onDailyGoalChange: (_) {},
          notificationsEnabled: true,
          onNotificationsToggle: () {},
          onSignOut: () {},
          user: const {
            'uid': 'u1',
            'phoneNumber': '',
            'displayName': 'Test User',
            'email': 'test@example.com',
          },
          language: 'en',
          onLanguageChange: (_) {},
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Settings'), findsOneWidget);
    expect(find.text('Daily Goal'), findsOneWidget);
    expect(find.text('Notifications'), findsOneWidget);
    expect(find.text('Language'), findsOneWidget);
  });
}
