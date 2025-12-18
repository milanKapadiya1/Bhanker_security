import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';

import 'theme/app_theme.dart';
import 'screens/calculator_screen.dart';
import 'screens/employees_screen.dart';
import 'screens/history_screen.dart';
import 'screens/splash_screen.dart';

void main() {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  // Preserve native white screen until Flutter takes over
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  runApp(const BhankerCalApp());
}

class BhankerCalApp extends StatelessWidget {
  const BhankerCalApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Remove native splash immediately when possible as our Custom Splash is the first screen
    FlutterNativeSplash.remove();

    return ScreenUtilInit(
      designSize: const Size(360, 690), // Standard Android design size
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MaterialApp(
          title: 'Bhanker Crops Management',
          theme: AppTheme.lightTheme,
          debugShowCheckedModeBanner: false,
          home: const SplashScreen(), // Start with Custom Splash
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
