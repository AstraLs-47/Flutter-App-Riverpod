// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_test/flutter_test.dart';

// Project imports:
import 'package:gym_app/features/auth/data/auth_service.dart';
import 'package:gym_app/features/profile/presentation/screens/profile_screen.dart';

void main() {
  testWidgets('Profile screen shows a delete account button', (
    WidgetTester tester,
  ) async {
    AuthService.currentUserName = 'Alex Morgan';
    AuthService.currentUserEmail = 'alex@example.com';

    await tester.pumpWidget(const MaterialApp(home: ProfileScreen()));

    expect(find.text('Delete Account'), findsOneWidget);
  });
}
