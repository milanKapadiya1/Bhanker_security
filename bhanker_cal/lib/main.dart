import 'package:flutter/material.dart';

import 'theme/app_theme.dart';
import 'screens/calculator_screen.dart';
import 'screens/employees_screen.dart';
import 'screens/history_screen.dart';

void main() {
  runApp(const BhankerCalApp());
}

class BhankerCalApp extends StatelessWidget {
  const BhankerCalApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BhankerCal',
      theme: AppTheme.lightTheme,
      debugShowCheckedModeBanner: false,
      initialRoute: CalculatorScreen.routeName,
      routes: {
        CalculatorScreen.routeName: (context) => const CalculatorScreen(),
        EmployeesScreen.routeName: (context) => const EmployeesScreen(),
        HistoryScreen.routeName: (context) => const HistoryScreen(),
      },
    );
  }
}
