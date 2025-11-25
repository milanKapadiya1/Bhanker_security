import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bhanker_cal/main.dart';

void main() {
  testWidgets('BhankerCal smoke test', (WidgetTester tester) async {
    // Set surface size to match design size for ScreenUtil
    await tester.binding.setSurfaceSize(const Size(360, 690));

    // Build our app and trigger a frame.
    await tester.pumpWidget(const BhankerCalApp());

    // Verify that the app title is present.
    expect(find.text('Salary Calculator'), findsOneWidget);
  });
}
