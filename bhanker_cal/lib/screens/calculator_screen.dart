import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../models/employee.dart';
import '../models/calculation_result.dart';
import '../theme/app_theme.dart';
import '../widgets/app_drawer.dart';
import '../widgets/month_picker_dialog.dart';
import '../services/employee_service.dart';
import '../services/salary_service.dart';
import '../utils/currency_input_formatter.dart';

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
  final TextEditingController _pointSalaryController =
      TextEditingController(); // New Point Salary Controller
  final TextEditingController _daysController = TextEditingController();
  final TextEditingController _wcController = TextEditingController();
  final TextEditingController _uniformController = TextEditingController();
  final TextEditingController _advanceController = TextEditingController();
  CalculationResult? _currentResult;
  String _nameInput = '';
  final ValueNotifier<bool> _isCalculatedNotifier =
      ValueNotifier(false); // Track calculation state via ValueNotifier

  // History List
  List<CalculationResult> _history = [];

  // Services
  final _employeeService = EmployeeService();
  final _salaryService = SalaryService();

  // Key to reset Autocomplete
  Key _autocompleteKey = UniqueKey();

  @override
  void initState() {
    super.initState();
    _loadSession();
  }

  Future<void> _loadSession() async {
    final session = await _salaryService.getSession();
    if (mounted) {
      setState(() {
        _history = session;
        if (_history.isNotEmpty) {
          _currentResult = _history.first;
        }
      });
    }
  }

  @override
  void dispose() {
    _salaryController.dispose();
    _pointSalaryController.dispose();
    _daysController.dispose();
    _wcController.dispose();
    _uniformController.dispose();
    _advanceController.dispose();
    _isCalculatedNotifier.dispose();
    super.dispose();
  }

  void _addNewEmployee() {
    if (_nameInput.trim().isEmpty) return;

    final double salary =
        CurrencyInputFormatter.parseAmount(_salaryController.text);
    if (salary <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Please enter a valid monthly salary first.')),
      );
      return;
    }

    final newEmployee = Employee(
      name: _nameInput.trim(),
      monthlySalary: salary,
      pointSalary: 0.0, // Default for quick employee
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

  Future<void> _calculateSalary() async {
    final double salary =
        CurrencyInputFormatter.parseAmount(_salaryController.text);
    final int? days = int.tryParse(_daysController.text);
    final double wc = double.tryParse(_wcController.text) ?? 0;
    final double uniform = double.tryParse(_uniformController.text) ?? 0;
    final double advance = double.tryParse(_advanceController.text) ?? 0;

    // Allow calculation if we have a name (even if not saved as employee yet)
    // Salary is 0 if empty or invalid parse, but parseAmount returns 0.0 on fail, so check > 0
    if (salary > 0 &&
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

      final totalDeductions = wc + uniform + advance;
      final calculatedSalary =
          ((salary / totalDaysInMonth) * days) - totalDeductions;

      final result = CalculationResult(
        employeeName: employeeName,
        date: _selectedDate,
        monthlySalary: salary,
        pointSalary: CurrencyInputFormatter.parseAmount(
            _pointSalaryController.text), // Capture Point Salary
        presentDays: days,
        totalDays: totalDaysInMonth,
        calculatedSalary: calculatedSalary,
        wc: wc,
        uniform: uniform,
        advance: advance,
        isSaved: false, // Explicitly mark as unsaved
      );

      setState(() {
        _currentResult = result;
        _history.insert(0, result); // Add to top of history
      });
      _isCalculatedNotifier.value = true; // Disable button after calculation

      // Save to persistence (Session only)
      await _salaryService.saveSession(_history);
      // await _salaryService.saveCalculation(result); // Removed auto-save to history
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
      _pointSalaryController.clear();
      _daysController.clear();
      _wcController.clear();
      _uniformController.clear();
      _advanceController.clear();
      _currentResult = null;
      _autocompleteKey = UniqueKey(); // Reset autocomplete
    });
    _isCalculatedNotifier.value = false; // Re-enable button
  }

  void _resetAll() {
    setState(() {
      _selectedDate = DateTime.now();
      _clearForm();
      _history.clear();
    });
    _salaryService.clearSession();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Salary Calculator'),
          actions: [
            TextButton.icon(
              onPressed: _resetAll,
              icon: Icon(Icons.refresh, size: 18.sp),
              label: Text('Reset All', style: TextStyle(fontSize: 14.sp)),
              style:
                  TextButton.styleFrom(foregroundColor: AppTheme.textPrimary),
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
                              horizontal: 12.w, vertical: 10.h),
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
                                    fontSize: 16.sp,
                                    fontWeight: FontWeight.w500),
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
              const SizedBox(height: 10),

              // Employee Search (Autocomplete)
              Text('Select Employee',
                  style:
                      TextStyle(fontWeight: FontWeight.w600, fontSize: 16.sp)),
              const SizedBox(height: 4),
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
                        CurrencyInputFormatter.formatAmount(
                            selection.monthlySalary);
                    _pointSalaryController.text =
                        CurrencyInputFormatter.formatAmount(
                            selection.pointSalary);
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
                    decoration: InputDecoration(
                      isDense: true,
                      contentPadding: EdgeInsets.symmetric(
                          horizontal: 12.w, vertical: 10.h),
                      prefixIcon: const Icon(Icons.search),
                      hintText: 'Search or type new name...',
                    ),
                  );
                },
              ),
              const SizedBox(height: 30),

              // Monthly Salary
              const Text('Monthly Salary (₹)',
                  style: TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 4),
              TextField(
                controller: _salaryController,
                keyboardType: TextInputType.number,
                inputFormatters: [CurrencyInputFormatter()],
                decoration: InputDecoration(
                  isDense: true,
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
                  hintText: 'Enter monthly salary',
                ),
              ),
              const SizedBox(height: 12),

              // Point Salary (Read Only)
              const Text('Point Salary (₹)',
                  style: TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 4),
              TextField(
                controller: _pointSalaryController,
                readOnly: true,
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Money You Get'),
                      content:
                          Text('This is the Point Salary from employee data.'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Close'),
                        ),
                      ],
                    ),
                  );
                },
                decoration: InputDecoration(
                  isDense: true,
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
                  hintText: 'Point Salary',
                  filled: true,
                  fillColor: Colors.grey.shade100,
                ),
              ),
              const SizedBox(height: 12),

              // Deductions Row (WC, Uniform, Advance)
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('WC',
                            style: TextStyle(fontWeight: FontWeight.w600)),
                        const SizedBox(height: 4),
                        TextField(
                          controller: _wcController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            isDense: true,
                            contentPadding: EdgeInsets.symmetric(
                                horizontal: 12.w, vertical: 10.h),
                            hintText: 'WC',
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 16.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Uniform',
                            style: TextStyle(fontWeight: FontWeight.w600)),
                        const SizedBox(height: 4),
                        TextField(
                          controller: _uniformController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            isDense: true,
                            contentPadding: EdgeInsets.symmetric(
                                horizontal: 12.w, vertical: 10.h),
                            hintText: 'Uniform',
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 16.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Advance',
                            style: TextStyle(fontWeight: FontWeight.w600)),
                        const SizedBox(height: 4),
                        TextField(
                          controller: _advanceController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            isDense: true,
                            contentPadding: EdgeInsets.symmetric(
                                horizontal: 12.w, vertical: 10.h),
                            hintText: 'Advance',
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Present Days
              const Text('Present Days',
                  style: TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 4),
              TextField(
                controller: _daysController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  isDense: true,
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
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
                      padding: EdgeInsets.symmetric(vertical: 10.h),
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
                child: ValueListenableBuilder<bool>(
                  valueListenable: _isCalculatedNotifier,
                  builder: (context, isCalculated, child) {
                    return ElevatedButton.icon(
                      onPressed: isCalculated ? null : _calculateSalary,
                      icon: const Icon(Icons.calculate),
                      label: const Text('Calculate Salary'),
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 12.h),
                        textStyle: TextStyle(
                            fontSize: 16.sp, fontWeight: FontWeight.bold),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.r)),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),

              // Clear Form Button
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: _clearForm,
                  style: OutlinedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 12.h),
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
                      if (_currentResult!.wc > 0 ||
                          _currentResult!.uniform > 0 ||
                          _currentResult!.advance > 0) ...[
                        const SizedBox(height: 24),
                        Container(
                          width: double.infinity,
                          padding: EdgeInsets.all(16.r),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFEF2F2), // Light red
                            borderRadius: BorderRadius.circular(12.r),
                            border: Border.all(
                                color: const Color(0xFFFECACA)), // Red 200
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: EdgeInsets.all(6.r),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                          color: const Color(0xFFFECACA)),
                                    ),
                                    child: Icon(Icons.remove,
                                        size: 14.sp,
                                        color: const Color(0xFFB91C1C)),
                                  ),
                                  SizedBox(width: 8.w),
                                  Text(
                                    'Deductions',
                                    style: TextStyle(
                                        fontSize: 16.sp,
                                        fontWeight: FontWeight.bold,
                                        color:
                                            const Color(0xFF991B1B)), // Red 800
                                  ),
                                  const Spacer(),
                                  Text(
                                    '- ₹${NumberFormat('#,##0').format(_currentResult!.wc + _currentResult!.uniform + _currentResult!.advance)}',
                                    style: TextStyle(
                                        fontSize: 16.sp,
                                        fontWeight: FontWeight.bold,
                                        color: const Color(0xFFB91C1C)),
                                  ),
                                ],
                              ),
                              SizedBox(height: 12.h),
                              Divider(
                                  color:
                                      const Color(0xFFFECACA).withOpacity(0.5),
                                  height: 1),
                              SizedBox(height: 12.h),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  if (_currentResult!.wc > 0)
                                    _buildDeductionItem(
                                        'WC', _currentResult!.wc),
                                  if (_currentResult!.uniform > 0)
                                    _buildDeductionItem(
                                        'Uniform', _currentResult!.uniform),
                                  if (_currentResult!.advance > 0)
                                    _buildDeductionItem(
                                        'Advance', _currentResult!.advance),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
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
                                  onPressed: () async {
                                    if (_history.isEmpty) return;

                                    // Filter only unsaved items
                                    final unsavedItems = _history
                                        .where((item) => !item.isSaved)
                                        .toList();

                                    if (unsavedItems.isEmpty) {
                                      if (context.mounted) {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(const SnackBar(
                                          content: Text(
                                              'No new calculations to save.'),
                                          backgroundColor: Colors.orange,
                                        ));
                                      }
                                      return;
                                    }

                                    await _salaryService
                                        .saveBatch(unsavedItems);

                                    // Mark items as saved in local history
                                    setState(() {
                                      _history = _history.map((item) {
                                        if (!item.isSaved) {
                                          return item.copyWith(isSaved: true);
                                        }
                                        return item;
                                      }).toList();
                                    });

                                    // Update session with saved status
                                    await _salaryService.saveSession(_history);

                                    if (context.mounted) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(SnackBar(
                                        content: Text(
                                            'Saved ${unsavedItems.length} new calculations to History!'),
                                        backgroundColor: Colors.green,
                                      ));
                                    }
                                  },
                                  icon: Icon(Icons.save_alt, size: 16.sp),
                                  label: const Text('Save'),
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
                              padding:
                                  const EdgeInsets.symmetric(vertical: 8.0),
                              child: Column(
                                children: [
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
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
                                            '₹${NumberFormat('#,##0').format(item.calculatedSalary)}',
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
                                  const SizedBox(height: 4),
                                  // Profit
                                  Text(
                                    'Profit: +₹${NumberFormat('#,##0').format(item.profit)}',
                                    style: TextStyle(
                                      fontSize: 12.sp,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.green.shade700,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  // Deductions
                                  if (item.wc > 0 ||
                                      item.uniform > 0 ||
                                      item.advance > 0) ...[
                                    Wrap(
                                      children: [
                                        Text(
                                          'Deductions: ',
                                          style: TextStyle(
                                              color: AppTheme.textSecondary,
                                              fontSize: 13.sp),
                                        ),
                                        if (item.wc > 0)
                                          Text(
                                            'WC: ${NumberFormat('#,##0').format(item.wc)}  ',
                                            style: TextStyle(
                                                color: AppTheme.textSecondary,
                                                fontSize: 13.sp),
                                          ),
                                        if (item.uniform > 0)
                                          Text(
                                            'Uniform: ${NumberFormat('#,##0').format(item.uniform)}  ',
                                            style: TextStyle(
                                                color: AppTheme.textSecondary,
                                                fontSize: 13.sp),
                                          ),
                                        if (item.advance > 0)
                                          Text(
                                            'Adv: ${NumberFormat('#,##0').format(item.advance)}',
                                            style: TextStyle(
                                                color: AppTheme.textSecondary,
                                                fontSize: 13.sp),
                                          ),
                                      ],
                                    ),
                                  ],
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
      ),
    );
  }

  Widget _buildDeductionItem(String label, double amount) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12.sp,
            color: const Color(0xFF7F1D1D), // Red 900
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: 2.h),
        Text(
          '₹${NumberFormat('#,##0').format(amount)}',
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.bold,
            color: const Color(0xFFB91C1C), // Red 700
          ),
        ),
      ],
    );
  }
}
