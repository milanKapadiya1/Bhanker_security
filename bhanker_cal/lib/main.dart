import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';

import 'theme/app_theme.dart';
import 'screens/calculator_screen.dart';
import 'screens/employees_screen.dart';
import 'screens/history_screen.dart';

void main() {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  runApp(const BhankerCalApp());
}

class BhankerCalApp extends StatefulWidget {
  const BhankerCalApp({super.key});

  @override
  State<BhankerCalApp> createState() => _BhankerCalAppState();
}

class _BhankerCalAppState extends State<BhankerCalApp> {
  @override
  void initState() {
    super.initState();
    _removeSplash();
  }

  Future<void> _removeSplash() async {
    await Future.delayed(const Duration(seconds: 1));
    FlutterNativeSplash.remove();
  }

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(360, 690), // Standard Android design size
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
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
      },
    );
  }
}
