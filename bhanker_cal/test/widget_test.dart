import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bhanker_cal/main.dart';

import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('BhankerCal smoke test', (WidgetTester tester) async {
    // Mock SharedPreferences
    SharedPreferences.setMockInitialValues({});

    // Set surface size to match modern phone design size for ScreenUtil to avoid overflow
    await tester.binding.setSurfaceSize(const Size(412, 915));

    // Build our app and trigger a frame.
    await tester.pumpWidget(const BhankerCalApp());

    // Verify that the app title is present.
    // App redirects to EmployeesScreen after splash
    // Note: PumpAndSettle is needed if we were testing the splash transition,
    // but here we might need to pump enough time or just update expectation if splash is immediate in test env.
    // However, since we Mocked SharedPreferences, let's see.
    // Actually, simply checking for 'Employee Management' implies we expect to be there.
    // But splash has a 3 second timer.
    // using pumpAndSettle might be safer.

    await tester.pumpAndSettle(const Duration(seconds: 3));

    expect(find.text('Employee Management'), findsOneWidget);
  });
}
