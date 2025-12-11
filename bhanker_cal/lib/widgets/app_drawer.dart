import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../screens/calculator_screen.dart';
import '../screens/employees_screen.dart';
import '../screens/history_screen.dart';
import '../theme/app_theme.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final currentRoute = ModalRoute.of(context)?.settings.name;

    return Drawer(
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: EdgeInsets.fromLTRB(24.w, 60.h, 24.w, 24.h),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: EdgeInsets.all(4.r), // Reduced padding slightly
                  decoration: BoxDecoration(
                    color: Colors.white, // Changed from primaryColor
                    borderRadius: BorderRadius.circular(50.r), // Rounded
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(50.r),
                    child: Image.asset(
                      'assets/images/app_logo.jpg',
                      width: 72.sp, // Slightly larger to pop
                      height: 72.sp,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                SizedBox(height: 16.h),
                Text(
                  'BhankerCal',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimary,
                      ),
                ),
                SizedBox(height: 4.h),
                Text(
                  'Salary Calculator',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
          SizedBox(height: 24.h),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'NAVIGATION',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: AppTheme.textSecondary,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                      ),
                ),
                SizedBox(height: 16.h),
                _buildDrawerItem(
                  context,
                  icon: Icons.calculate_outlined,
                  title: 'Calculator',
                  route: CalculatorScreen.routeName,
                  isSelected: currentRoute == CalculatorScreen.routeName,
                ),
                _buildDrawerItem(
                  context,
                  icon: Icons.people_outline,
                  title: 'Employees',
                  route: EmployeesScreen.routeName,
                  isSelected: currentRoute == EmployeesScreen.routeName,
                ),
                _buildDrawerItem(
                  context,
                  icon: Icons.history,
                  title: 'History',
                  route: HistoryScreen.routeName,
                  isSelected: currentRoute == HistoryScreen.routeName,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String route,
    required bool isSelected,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: 8.h),
      decoration: BoxDecoration(
        color: isSelected ? Colors.grey.shade100 : Colors.transparent,
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: ListTile(
        leading: Icon(
          icon,
          color: isSelected ? AppTheme.primaryColor : AppTheme.textSecondary,
        ),
        title: Text(
          title,
          style: TextStyle(
            color: isSelected ? AppTheme.primaryColor : AppTheme.textPrimary,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
        onTap: () {
          if (isSelected) {
            Navigator.pop(context);
          } else {
            Navigator.pushReplacementNamed(context, route);
          }
        },
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.r),
        ),
      ),
    );
  }
}
