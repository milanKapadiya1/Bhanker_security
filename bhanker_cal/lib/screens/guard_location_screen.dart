import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:intl/intl.dart';
import '../models/employee.dart';
import '../models/relocation.dart';
import '../services/employee_service.dart';
import '../widgets/app_drawer.dart';
import '../theme/app_theme.dart';

class GuardLocationScreen extends StatefulWidget {
  static const routeName = '/guard-location';

  const GuardLocationScreen({super.key});

  @override
  State<GuardLocationScreen> createState() => _GuardLocationScreenState();
}

class _GuardLocationScreenState extends State<GuardLocationScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      if (_tabController.indexIsChanging ||
          _tabController.index != _currentIndex) {
        setState(() {
          _currentIndex = _tabController.index;
        });
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

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
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Guard Locations'),
            Tab(text: 'Relocation'),
          ],
        ),
      ),
      drawer: const AppDrawer(),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Tab 1: Guard Locations (Existing Logic)
          ListenableBuilder(
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
                        style: TextStyle(
                            fontSize: 16.sp, color: Colors.grey.shade600),
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        'Add location to employees to see them here',
                        style: TextStyle(
                            fontSize: 12.sp, color: Colors.grey.shade500),
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
                        tilePadding: EdgeInsets.symmetric(
                            horizontal: 16.w, vertical: 8.h),
                        leading: Container(
                          padding: EdgeInsets.all(8.r),
                          decoration: BoxDecoration(
                            color: AppTheme.primaryColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                          child: Icon(Icons.location_on,
                              color: AppTheme.primaryColor),
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
                                                    color:
                                                        Colors.grey.shade600);
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

          // Tab 2: Relocation
          _RelocationTab(),
        ],
      ),
      floatingActionButton: _currentIndex == 1
          ? FloatingActionButton(
              onPressed: () => _showAddRelocationDialog(context),
              backgroundColor: AppTheme.primaryColor,
              child: const Icon(Icons.add, color: Colors.white),
            )
          : null,
    );
  }
}

class _RelocationTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final employeeService = EmployeeService();
    return ListenableBuilder(
      listenable: employeeService,
      builder: (context, child) {
        final relocations = employeeService.relocations;
        // Sort by date descending
        final sortedRelocations = List<Relocation>.from(relocations)
          ..sort((a, b) => b.date.compareTo(a.date));

        if (sortedRelocations.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.history, size: 64.sp, color: Colors.grey.shade400),
                SizedBox(height: 16.h),
                Text(
                  'No relocation history',
                  style:
                      TextStyle(fontSize: 16.sp, color: Colors.grey.shade600),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: EdgeInsets.all(16.r),
          itemCount: sortedRelocations.length,
          itemBuilder: (context, index) {
            final item = sortedRelocations[index];
            return Card(
              elevation: 2,
              margin: EdgeInsets.only(bottom: 12.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Padding(
                padding: EdgeInsets.all(16.r),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          item.guardName,
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                        Text(
                          DateFormat('MMM d, y').format(item.date),
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8.h),
                    Row(
                      children: [
                        Icon(Icons.arrow_forward,
                            size: 16.sp, color: AppTheme.primaryColor),
                        SizedBox(width: 8.w),
                        Expanded(
                          child: Text(
                            '${item.originalLocation}  \u2794  ${item.newLocation}',
                            style: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8.h),
                    Divider(color: Colors.grey.shade200),
                    SizedBox(height: 8.h),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${item.startTime.format(context)} - ${item.endTime.format(context)} (${item.totalHours.toStringAsFixed(1)} hrs)',
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                        Text(
                          '₹${item.earnedAmount.toStringAsFixed(0)}',
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}

void _showAddRelocationDialog(BuildContext context) {
  final employeeService = EmployeeService();
  final employees = employeeService.employees;
  Employee? selectedEmployee;
  final newLocationController = TextEditingController();
  final amountController = TextEditingController();
  DateTime selectedDate = DateTime.now();
  TimeOfDay startTime = const TimeOfDay(hour: 9, minute: 0);
  TimeOfDay endTime = const TimeOfDay(hour: 17, minute: 0);

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
    ),
    builder: (context) => StatefulBuilder(
      builder: (context, setState) {
        return Padding(
          padding: EdgeInsets.fromLTRB(24.w, 24.h, 24.w,
              MediaQuery.of(context).viewInsets.bottom + 24.h),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Add Relocation',
                style: TextStyle(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 24.h),
              DropdownButtonFormField<Employee>(
                decoration: InputDecoration(
                  labelText: 'Select Guard',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.r)),
                ),
                items: employees.map((e) {
                  return DropdownMenuItem(
                    value: e,
                    child: Text(e.name),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedEmployee = value;
                  });
                },
              ),
              if (selectedEmployee != null) ...[
                SizedBox(height: 8.h),
                Text(
                  'Original Location: ${selectedEmployee!.location ?? "N/A"}',
                  style:
                      TextStyle(color: Colors.grey.shade600, fontSize: 12.sp),
                ),
              ],
              SizedBox(height: 16.h),
              TextField(
                controller: newLocationController,
                decoration: InputDecoration(
                  labelText: 'New Location',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.r)),
                ),
              ),
              SizedBox(height: 16.h),
              Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: () async {
                        final date = await showDatePicker(
                          context: context,
                          initialDate: selectedDate,
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2100),
                        );
                        if (date != null) {
                          setState(() => selectedDate = date);
                        }
                      },
                      child: InputDecorator(
                        decoration: InputDecoration(
                          labelText: 'Date',
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12.r)),
                        ),
                        child:
                            Text(DateFormat('MMM d, y').format(selectedDate)),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16.h),
              Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: () async {
                        final time = await showTimePicker(
                            context: context, initialTime: startTime);
                        if (time != null) {
                          setState(() {
                            startTime = time;
                          });
                        }
                      },
                      child: InputDecorator(
                        decoration: InputDecoration(
                          labelText: 'Start Time',
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12.r)),
                        ),
                        child: Text(startTime.format(context)),
                      ),
                    ),
                  ),
                  SizedBox(width: 16.w),
                  Expanded(
                    child: InkWell(
                      onTap: () async {
                        final time = await showTimePicker(
                            context: context, initialTime: endTime);
                        if (time != null) {
                          setState(() {
                            endTime = time;
                          });
                        }
                      },
                      child: InputDecorator(
                        decoration: InputDecoration(
                          labelText: 'End Time',
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12.r)),
                        ),
                        child: Text(endTime.format(context)),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16.h),
              TextField(
                controller: amountController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Earned Amount',
                  prefixText: '₹ ',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.r)),
                ),
              ),
              SizedBox(height: 24.h),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    if (selectedEmployee == null ||
                        newLocationController.text.isEmpty ||
                        amountController.text.isEmpty) {
                      return;
                    }

                    final double start =
                        startTime.hour + startTime.minute / 60.0;
                    final double end = endTime.hour + endTime.minute / 60.0;
                    double hours = end - start;
                    if (hours < 0) hours += 24;

                    final relocation = Relocation(
                      id: DateTime.now().millisecondsSinceEpoch.toString(),
                      guardId: selectedEmployee!.id ?? '',
                      guardName: selectedEmployee!.name,
                      originalLocation: selectedEmployee!.location ?? 'Unknown',
                      newLocation: newLocationController.text,
                      date: selectedDate,
                      startTime: startTime,
                      endTime: endTime,
                      totalHours: hours,
                      earnedAmount: double.parse(amountController.text),
                    );

                    employeeService.addRelocation(relocation);
                    Navigator.pop(context);
                  },
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 12.h),
                    child: const Text('Save Relocation'),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    ),
  );
}
