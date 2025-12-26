import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../models/employee.dart';
import '../services/employee_service.dart';
import '../widgets/app_drawer.dart';
import '../theme/app_theme.dart';

class GuardLocationScreen extends StatefulWidget {
  static const routeName = '/guard-location';

  const GuardLocationScreen({super.key});

  @override
  State<GuardLocationScreen> createState() => _GuardLocationScreenState();
}

class _GuardLocationScreenState extends State<GuardLocationScreen> {
  // Helper to group employees by location
  Map<String, List<Employee>> _groupEmployeesByLocation(
      List<Employee> employees) {
    final Map<String, List<Employee>> data = {};

    for (var emp in employees) {
      // Normalize location: trim and check validity
      final rawLoc = emp.location?.trim();
      if (rawLoc != null && rawLoc.isNotEmpty) {
        // Capitalize for consistency if desired, or keep as is
        if (!data.containsKey(rawLoc)) {
          data[rawLoc] = [];
        }
        data[rawLoc]!.add(emp);
      }
    }
    return data;
  }

  @override
  Widget build(BuildContext context) {
    final employeeService =
        EmployeeService(); // In a real app with Provider, use context.watch<EmployeeService>()

    return Scaffold(
      appBar: AppBar(
        title: const Text('Guard Locations'),
      ),
      drawer: const AppDrawer(),
      body: ListenableBuilder(
        listenable: employeeService,
        builder: (context, child) {
          final employees = employeeService.employees;
          final groupedData = _groupEmployeesByLocation(employees);
          final sortedLocations = groupedData.keys.toList()..sort();

          if (sortedLocations.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.location_off_outlined,
                      size: 64.sp, color: Colors.grey.shade400),
                  SizedBox(height: 16.h),
                  Text(
                    'No locations found',
                    style:
                        TextStyle(fontSize: 16.sp, color: Colors.grey.shade600),
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    'Add location to employees to see them here',
                    style:
                        TextStyle(fontSize: 12.sp, color: Colors.grey.shade500),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: EdgeInsets.all(16.r),
            itemCount: sortedLocations.length,
            itemBuilder: (context, index) {
              final location = sortedLocations[index];
              final guards = groupedData[location]!;

              return Card(
                elevation: 2,
                margin: EdgeInsets.only(bottom: 16.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Theme(
                  data: Theme.of(context)
                      .copyWith(dividerColor: Colors.transparent),
                  child: ExpansionTile(
                    tilePadding:
                        EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                    leading: Container(
                      padding: EdgeInsets.all(8.r),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child:
                          Icon(Icons.location_on, color: AppTheme.primaryColor),
                    ),
                    title: Text(
                      location,
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    subtitle: Text(
                      '${guards.length} Guard${guards.length == 1 ? '' : 's'} Posted',
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.grey.shade50,
                          borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(12.r),
                            bottomRight: Radius.circular(12.r),
                          ),
                        ),
                        child: Column(
                          children: guards.map((employee) {
                            return ListTile(
                              contentPadding: EdgeInsets.symmetric(
                                  horizontal: 16.w, vertical: 4.h),
                              leading: Container(
                                width: 40.r,
                                height: 40.r,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.grey.shade300,
                                ),
                                child: ClipOval(
                                  child: employee.photoPath != null
                                      ? Image.file(
                                          File(employee.photoPath!),
                                          fit: BoxFit.cover,
                                          gaplessPlayback: true,
                                          errorBuilder:
                                              (context, error, stackTrace) {
                                            return Icon(Icons.person,
                                                size: 24.sp,
                                                color: Colors.grey.shade600);
                                          },
                                        )
                                      : Icon(Icons.person,
                                          size: 24.sp,
                                          color: Colors.grey.shade600),
                                ),
                              ),
                              title: Text(
                                employee.name,
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              subtitle: Text(
                                employee.role,
                                style: TextStyle(fontSize: 12.sp),
                              ),
                              trailing: Icon(Icons.chevron_right,
                                  size: 20.sp, color: Colors.grey.shade400),
                              onTap: () {
                                // Optional: Navigate to detail or edit
                              },
                            );
                          }).toList(),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
