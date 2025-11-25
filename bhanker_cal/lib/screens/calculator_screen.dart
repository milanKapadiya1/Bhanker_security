import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../models/employee.dart';
import '../models/calculation_result.dart';
import '../theme/app_theme.dart';
import '../widgets/app_drawer.dart';
import '../widgets/month_picker_dialog.dart';
import '../services/employee_service.dart';

class CalculatorScreen extends StatefulWidget {
  static const routeName = '/calculator';

  const CalculatorScreen({super.key});

  @override
  State<CalculatorScreen> createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen> {
  DateTime _selectedDate = DateTime.now();
  Employee? _selectedEmployee;
  final TextEditingController _salaryController = TextEditingController();
  final TextEditingController _daysController = TextEditingController();
  CalculationResult? _currentResult;
  String _nameInput = '';

  // History List
  final List<CalculationResult> _history = [];

  // Employee Service
  final _employeeService = EmployeeService();

  // Key to reset Autocomplete
  Key _autocompleteKey = UniqueKey();

  @override
  void dispose() {
    _salaryController.dispose();
    _daysController.dispose();
    super.dispose();
  }

  void _addNewEmployee() {
    if (_nameInput.trim().isEmpty) return;

    final double salary = double.tryParse(_salaryController.text) ?? 0;
    if (salary <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Please enter a valid monthly salary first.')),
      );
      return;
    }

    final newEmployee = Employee(
      id: null, // ID is optional/null for new employees added on the fly
      name: _nameInput.trim(),
      role: 'Employee',
      monthlySalary: salary,
    );

    _employeeService.addEmployee(newEmployee);

    setState(() {
      _selectedEmployee = newEmployee;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Saved new employee: ${newEmployee.name}'),
        backgroundColor: Colors.green.shade400,
      ),
    );
  }

  void _calculateSalary() {
    final double? salary = double.tryParse(_salaryController.text);
    final int? days = int.tryParse(_daysController.text);

    // Allow calculation if we have a name (even if not saved as employee yet)
    if (salary != null &&
        days != null &&
        (_selectedEmployee != null || _nameInput.isNotEmpty)) {
      final totalDaysInMonth =
          DateUtils.getDaysInMonth(_selectedDate.year, _selectedDate.month);

      if (days > totalDaysInMonth) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Error: Present days ($days) cannot exceed total days in month ($totalDaysInMonth).',
              style: const TextStyle(color: Colors.white),
            ),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
        return;
      }

      final employeeName = _selectedEmployee?.name ?? _nameInput;
      final employeeId = _selectedEmployee?.id ?? 'TEMP';

      final calculatedSalary = (salary / totalDaysInMonth) * days;

      final result = CalculationResult(
        employeeName: employeeName,
        employeeId: employeeId,
        date: _selectedDate,
        monthlySalary: salary,
        presentDays: days,
        totalDays: totalDaysInMonth,
        calculatedSalary: calculatedSalary,
      );

      setState(() {
        _currentResult = result;
        _history.insert(0, result); // Add to top of history
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
              'Please select an employee (or enter name) and fill all fields.'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _clearForm() {
    setState(() {
      _selectedEmployee = null;
      _nameInput = '';
      _salaryController.clear();
      _daysController.clear();
      _currentResult = null;
      _autocompleteKey = UniqueKey(); // Reset autocomplete
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Salary Calculator'),
        actions: [
          TextButton.icon(
            onPressed: () {
              setState(() {
                _selectedDate = DateTime.now();
                _clearForm();
                _history.clear();
              });
            },
            icon: Icon(Icons.refresh, size: 18.sp),
            label: Text('Reset All', style: TextStyle(fontSize: 14.sp)),
            style: TextButton.styleFrom(foregroundColor: AppTheme.textPrimary),
          ),
          SizedBox(width: 8.w),
        ],
      ),
      drawer: const AppDrawer(),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0.r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Month Settings Card
            Card(
              color: const Color(0xFFEEF2FF), // Light indigo background
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16.r),
              ),
              child: Padding(
                padding: EdgeInsets.all(16.0.r),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.settings_outlined,
                            color: AppTheme.primaryColor, size: 20.sp),
                        SizedBox(width: 8.w),
                        Text(
                          'Month Settings',
                          style: TextStyle(
                              fontSize: 16.sp, fontWeight: FontWeight.bold),
                        ),
                        const Spacer(),
                        Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 10.w, vertical: 4.h),
                          decoration: BoxDecoration(
                            color: AppTheme.primaryColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20.r),
                          ),
                          child: Text(
                            'One-time setup',
                            style: TextStyle(
                              color: AppTheme.primaryColor,
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Text('Select Month & Year',
                        style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF374151))),
                    const SizedBox(height: 8),
                    InkWell(
                      onTap: () async {
                        final DateTime? picked = await showDialog<DateTime>(
                          context: context,
                          builder: (context) =>
                              MonthPickerDialog(initialDate: _selectedDate),
                        );
                        if (picked != null) {
                          setState(() {
                            _selectedDate = picked;
                          });
                        }
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 16.w, vertical: 12.h),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8.r),
                          border: Border.all(color: Colors.grey.shade200),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              DateFormat('MMMM, yyyy').format(_selectedDate),
                              style: TextStyle(
                                  fontSize: 16.sp, fontWeight: FontWeight.w500),
                            ),
                            Icon(Icons.calendar_today_outlined, size: 20.sp),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Total days will be set automatically based on your selection.',
                      style: TextStyle(
                          fontSize: 12.sp, color: AppTheme.textSecondary),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Employee Search (Autocomplete)
            Text('Select Employee',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16.sp)),
            const SizedBox(height: 8),
            Autocomplete<Employee>(
              key: _autocompleteKey,
              optionsBuilder: (TextEditingValue textEditingValue) {
                if (textEditingValue.text.isEmpty) {
                  return const Iterable<Employee>.empty();
                }
                return _employeeService.search(textEditingValue.text);
              },
              displayStringForOption: (Employee option) => option.name,
              onSelected: (Employee selection) {
                setState(() {
                  _selectedEmployee = selection;
                  _nameInput = selection.name;
                  _salaryController.text =
                      selection.monthlySalary.toStringAsFixed(0);
                });
              },
              fieldViewBuilder: (context, textEditingController, focusNode,
                  onFieldSubmitted) {
                return TextField(
                  controller: textEditingController,
                  focusNode: focusNode,
                  onChanged: (value) {
                    setState(() {
                      _nameInput = value;
                      // Reset selected employee if user types something new
                      if (_selectedEmployee != null &&
                          value != _selectedEmployee!.name) {
                        _selectedEmployee = null;
                      }
                    });
                  },
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.search),
                    hintText: 'Search or type new name...',
                  ),
                );
              },
            ),
            const SizedBox(height: 16),

            // Monthly Salary
            const Text('Monthly Salary (₹)',
                style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            TextField(
              controller: _salaryController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                hintText: 'Enter monthly salary',
              ),
            ),
            const SizedBox(height: 16),

            // Present Days
            const Text('Present Days',
                style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            TextField(
              controller: _daysController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                hintText: 'Enter present days',
              ),
            ),
            const SizedBox(height: 24),

            // Save New Employee Button (Visible only if new employee)
            if (_selectedEmployee == null && _nameInput.isNotEmpty) ...[
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: _addNewEmployee,
                  icon: const Icon(Icons.person_add_alt_1),
                  label: const Text('Save New Employee'),
                  style: OutlinedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 12.h),
                    side: const BorderSide(color: Colors.blue),
                    foregroundColor: Colors.blue,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.r)),
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Calculate Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _calculateSalary,
                icon: const Icon(Icons.calculate),
                label: const Text('Calculate Salary'),
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 16.h),
                  textStyle:
                      TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.r)),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Clear Form Button
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: _clearForm,
                style: OutlinedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 16.h),
                  side: BorderSide(color: Colors.grey.shade300),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.r)),
                  foregroundColor: AppTheme.textPrimary,
                ),
                child: const Text('Clear Form',
                    style: TextStyle(fontWeight: FontWeight.w600)),
              ),
            ),

            // Result Card (Mint Green)
            if (_currentResult != null) ...[
              const SizedBox(height: 32),
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(24.r),
                decoration: BoxDecoration(
                  color: const Color(0xFFECFDF5), // Mint green background
                  borderRadius: BorderRadius.circular(16.r),
                  border: Border.all(color: const Color(0xFFD1FAE5)),
                ),
                child: Column(
                  children: [
                    Text(
                      'Salary Calculation',
                      style: TextStyle(
                          fontSize: 20.sp,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF064E3B)),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Based on attendance',
                      style: TextStyle(
                          color: const Color(0xFF065F46).withOpacity(0.7)),
                    ),
                    const SizedBox(height: 24),
                    const Text('Per Day',
                        style: TextStyle(
                            color: Color(0xFF065F46),
                            fontWeight: FontWeight.w500)),
                    const SizedBox(height: 4),
                    Text(
                      '₹${NumberFormat('#,##0.00').format(_currentResult!.perDayAmount)}',
                      style: TextStyle(
                          fontSize: 24.sp,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF111827)),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.calendar_today,
                            size: 16.sp, color: Color(0xFF065F46)),
                        SizedBox(width: 8.w),
                        const Text('Attendance',
                            style: TextStyle(
                                color: Color(0xFF065F46),
                                fontWeight: FontWeight.w500)),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${_currentResult!.presentDays}/${_currentResult!.totalDays}',
                      style: TextStyle(
                          fontSize: 24.sp,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF111827)),
                    ),
                    const SizedBox(height: 24),
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.symmetric(vertical: 16.h),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12.r),
                        border: Border.all(color: const Color(0xFFD1FAE5)),
                      ),
                      child: Column(
                        children: [
                          const Text(
                            'Final Calculated Salary',
                            style: TextStyle(
                                color: Color(0xFF4B5563),
                                fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '₹${NumberFormat('#,##0').format(_currentResult!.calculatedSalary)}',
                            style: TextStyle(
                              fontSize: 36.sp,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF059669), // Green text
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],

            // History Section
            if (_history.isNotEmpty) ...[
              const SizedBox(height: 40),
              Card(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16.r)),
                child: Padding(
                  padding: EdgeInsets.all(16.0.r),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Calculation',
                                  style: TextStyle(
                                      fontSize: 18.sp,
                                      fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  'History',
                                  style: TextStyle(
                                      fontSize: 18.sp,
                                      fontWeight: FontWeight.bold),
                                ),
                                SizedBox(height: 4.h),
                                Text(
                                  '${_history.length} calculations • Total: ₹${NumberFormat('#,##0').format(_history.fold(0.0, (sum, item) => sum + item.calculatedSalary))}',
                                  style: TextStyle(
                                      color: AppTheme.textSecondary,
                                      fontSize: 13.sp),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                          Row(
                            children: [
                              OutlinedButton.icon(
                                onPressed: () {}, // Placeholder
                                icon: Icon(Icons.copy, size: 16.sp),
                                label: const Text('Copy'),
                                style: OutlinedButton.styleFrom(
                                  padding:
                                      EdgeInsets.symmetric(horizontal: 12.w),
                                  minimumSize: Size.zero,
                                  tapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                ),
                              ),
                              const SizedBox(width: 8),
                              OutlinedButton.icon(
                                onPressed: () {}, // Placeholder
                                icon: Icon(Icons.print, size: 16.sp),
                                label: const Text('Print'),
                                style: OutlinedButton.styleFrom(
                                  padding:
                                      EdgeInsets.symmetric(horizontal: 12.w),
                                  minimumSize: Size.zero,
                                  tapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                ),
                              ),
                            ],
                          )
                        ],
                      ),
                      const SizedBox(height: 16),
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _history.length,
                        separatorBuilder: (context, index) =>
                            Divider(color: Colors.grey.shade100),
                        itemBuilder: (context, index) {
                          final item = _history[index];
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            child: Column(
                              children: [
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    CircleAvatar(
                                      backgroundColor: AppTheme.primaryColor,
                                      radius: 20.r,
                                      child: Icon(Icons.person_outline,
                                          color: Colors.white, size: 20.sp),
                                    ),
                                    SizedBox(width: 12.w),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            item.employeeName,
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16.sp),
                                          ),
                                          Text(
                                            DateFormat('yyyy-MM')
                                                .format(item.date),
                                            style: TextStyle(
                                                color: AppTheme.textSecondary,
                                                fontSize: 12.sp),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      children: [
                                        Text(
                                          '₹${NumberFormat('#,##0.###').format(item.calculatedSalary)}',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 18.sp,
                                            color: const Color(0xFF059669),
                                          ),
                                        ),
                                        Text(
                                          '${item.presentDays}/${item.totalDays} days',
                                          style: TextStyle(
                                              color: AppTheme.textSecondary,
                                              fontSize: 12.sp),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                SizedBox(height: 8.h),
                                Row(
                                  children: [
                                    Text(
                                      'Monthly: ₹${NumberFormat('#,##0').format(item.monthlySalary)}',
                                      style: TextStyle(
                                          color: AppTheme.textSecondary,
                                          fontSize: 13.sp),
                                    ),
                                    SizedBox(width: 16.w),
                                    Icon(Icons.calendar_today,
                                        size: 12.sp,
                                        color: AppTheme.textSecondary),
                                    SizedBox(width: 4.w),
                                    Text(
                                      'Per day: ₹${NumberFormat('#,##0.00').format(item.perDayAmount)}',
                                      style: TextStyle(
                                          color: AppTheme.textSecondary,
                                          fontSize: 13.sp),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ],
            SizedBox(height: 40.h),
          ],
        ),
      ),
    );
  }
}
