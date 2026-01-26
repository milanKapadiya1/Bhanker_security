import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import '../models/employee.dart';
import '../theme/app_theme.dart';
import '../widgets/app_drawer.dart';

import '../services/employee_service.dart';
import '../utils/currency_input_formatter.dart';

class EmployeesScreen extends StatefulWidget {
  static const routeName = '/employees';

  const EmployeesScreen({super.key});

  @override
  State<EmployeesScreen> createState() => _EmployeesScreenState();
}

class _EmployeesScreenState extends State<EmployeesScreen> {
  String _searchQuery = '';

  Future<String?> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile == null) return null;

    try {
      // Get the Application Documents Directory
      final directory = await getApplicationDocumentsDirectory();

      // Create a dedicated subdirectory for employee photos
      final photosDir = Directory('${directory.path}/employee_photos');
      if (!await photosDir.exists()) {
        await photosDir.create(recursive: true);
      }

      // Generate a unique filename using timestamp
      final fileName =
          'employee_${DateTime.now().millisecondsSinceEpoch}${path.extension(pickedFile.path)}';
      final savedImage =
          await File(pickedFile.path).copy('${photosDir.path}/$fileName');

      return savedImage.path;
    } catch (e) {
      debugPrint('Error saving image: $e');
      return null;
    }
  }

  void _showAddEmployeeDialog(BuildContext context) {
    final nameController = TextEditingController();
    final salaryController = TextEditingController();
    final pointSalaryController = TextEditingController(); // New controller
    final locationController = TextEditingController();
    final residentialController = TextEditingController();
    final adharController = TextEditingController();
    final phoneController = TextEditingController();
    String? selectedPhotoPath;
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            insetPadding: EdgeInsets.symmetric(
                horizontal: 0.1.sw, vertical: 24.h), // Consistent width
            title: const Text('Add New Employee'),
            content: Form(
              key: formKey,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    GestureDetector(
                      onTap: () async {
                        final path = await _pickImage();
                        if (path != null) {
                          setState(() {
                            selectedPhotoPath = path;
                          });
                        }
                      },
                      child: Container(
                        width: 80.r,
                        height: 80.r,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.grey.shade200,
                        ),
                        child: ClipOval(
                          child: selectedPhotoPath != null
                              ? Image.file(
                                  File(selectedPhotoPath!),
                                  fit: BoxFit.cover,
                                  gaplessPlayback: true,
                                )
                              : Icon(Icons.add_a_photo,
                                  size: 30.sp, color: Colors.grey.shade600),
                        ),
                      ),
                    ),
                    SizedBox(height: 24.h),
                    // 1. Name
                    TextFormField(
                      controller: nameController,
                      decoration: const InputDecoration(labelText: 'Name'),
                      validator: (value) =>
                          value?.isEmpty ?? true ? 'Please enter a name' : null,
                    ),
                    // 2. Monthly Salary
                    TextFormField(
                      controller: salaryController,
                      decoration:
                          const InputDecoration(labelText: 'Monthly Salary'),
                      keyboardType: TextInputType.number,
                      inputFormatters: [CurrencyInputFormatter()],
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a salary';
                        }
                        // Remove commas for validation
                        if (double.tryParse(value.replaceAll(',', '')) ==
                            null) {
                          return 'Please enter a valid number';
                        }
                        return null;
                      },
                    ),
                    // New Point Salary Field
                    TextFormField(
                      controller: pointSalaryController,
                      decoration: const InputDecoration(
                          labelText: 'Point Salary',
                          hintText: 'Enter Point Salary'),
                      keyboardType: TextInputType.number,
                      inputFormatters: [CurrencyInputFormatter()],
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a point salary';
                        }
                        if (double.tryParse(value.replaceAll(',', '')) ==
                            null) {
                          return 'Please enter a valid number';
                        }
                        return null;
                      },
                    ),
                    // 3. Point (Moved to third position)
                    TextFormField(
                      controller: locationController,
                      decoration: const InputDecoration(
                          labelText: 'Point', hintText: 'Enter Point'),
                      validator: (value) => value?.isEmpty ?? true
                          ? 'Please enter a point'
                          : null,
                    ),
                    // 4. Home Address (Renamed from Residential Address)
                    TextFormField(
                      controller: residentialController,
                      decoration: const InputDecoration(
                          labelText: 'Home Address (Optional)',
                          hintText: 'Enter Home Address'),
                      maxLines: 2,
                      minLines: 1,
                    ),
                    // 5. Adhar Card
                    TextFormField(
                      controller: adharController,
                      decoration: const InputDecoration(
                          labelText: 'Adhar Card (Optional)',
                          hintText: 'Enter Adhar Card Number'),
                    ),
                    // 6. Phone Number (New)
                    TextFormField(
                      controller: phoneController,
                      decoration: const InputDecoration(
                          labelText: 'Phone Number (Optional)',
                          hintText: 'Enter Phone Number'),
                      keyboardType: TextInputType.phone,
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  if (formKey.currentState?.validate() ?? false) {
                    final newEmployee = Employee(
                      name: nameController.text.trim(),
                      monthlySalary: CurrencyInputFormatter.parseAmount(
                          salaryController.text),
                      pointSalary: CurrencyInputFormatter.parseAmount(
                          pointSalaryController.text),
                      adharCard: adharController.text.trim().isEmpty
                          ? null
                          : adharController.text.trim(),
                      location: locationController.text.trim(),
                      residentialAddress:
                          residentialController.text.trim().isEmpty
                              ? null
                              : residentialController.text.trim(),
                      photoPath: selectedPhotoPath,
                      phoneNumber: phoneController.text.trim().isEmpty
                          ? null
                          : phoneController.text.trim(),
                    );
                    EmployeeService().addEmployee(newEmployee);
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Added employee: ${newEmployee.name}'),
                        backgroundColor: Colors.green.shade400,
                      ),
                    );
                  }
                },
                child: const Text('Add'),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showEditEmployeeDialog(BuildContext context, Employee employee) {
    final nameController = TextEditingController(text: employee.name);
    final salaryController = TextEditingController(
        text: CurrencyInputFormatter.formatAmount(employee.monthlySalary));
    final pointSalaryController = TextEditingController(
        text: CurrencyInputFormatter.formatAmount(employee.pointSalary));
    final adharController =
        TextEditingController(text: employee.adharCard ?? '');
    final locationController =
        TextEditingController(text: employee.location ?? '');
    final residentialController =
        TextEditingController(text: employee.residentialAddress ?? '');
    final phoneController =
        TextEditingController(text: employee.phoneNumber ?? '');
    String? selectedPhotoPath = employee.photoPath;
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            insetPadding: EdgeInsets.symmetric(
                horizontal: 0.1.sw, vertical: 24.h), // 80% screen width
            title: const Text('Edit Employee'),
            content: Form(
              key: formKey,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    GestureDetector(
                      onTap: () async {
                        final path = await _pickImage();
                        if (path != null) {
                          setState(() {
                            selectedPhotoPath = path;
                          });
                        }
                      },
                      child: Container(
                        width: 80.r,
                        height: 80.r,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.grey.shade200,
                        ),
                        child: ClipOval(
                          child: selectedPhotoPath != null
                              ? Image.file(
                                  File(selectedPhotoPath!),
                                  fit: BoxFit.cover,
                                  gaplessPlayback: true,
                                )
                              : Icon(Icons.add_a_photo,
                                  size: 30.sp, color: Colors.grey.shade600),
                        ),
                      ),
                    ),
                    SizedBox(height: 24.h),
                    // 1. Name
                    _buildLabeledTextField(
                      controller: nameController,
                      label: 'Name',
                      validator: (value) =>
                          value?.isEmpty ?? true ? 'Please enter a name' : null,
                    ),
                    SizedBox(height: 16.h),
                    // 2. Salary
                    _buildLabeledTextField(
                      controller: salaryController,
                      label: 'Monthly Salary',
                      isNumber: true,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a salary';
                        }
                        if (double.tryParse(value.replaceAll(',', '')) ==
                            null) {
                          return 'Please enter a valid number';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 16.h),
                    // New Point Salary Field in Edit
                    _buildLabeledTextField(
                      controller: pointSalaryController,
                      label: 'Point Salary',
                      isNumber: true,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a point salary';
                        }
                        if (double.tryParse(value.replaceAll(',', '')) ==
                            null) {
                          return 'Please enter a valid number';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 16.h),
                    // 3. Point (Third)
                    _buildLabeledTextField(
                      controller: locationController,
                      label: 'Point',
                      validator: (value) => value?.isEmpty ?? true
                          ? 'Please enter a point'
                          : null,
                    ),
                    SizedBox(height: 16.h),
                    // 4. Home Address
                    _buildLabeledTextField(
                      controller: residentialController,
                      label: 'Home Address',
                      maxLines: 2,
                    ),
                    SizedBox(height: 16.h),
                    // 5. Adhar
                    _buildLabeledTextField(
                      controller: adharController,
                      label: 'Adhar Card (Optional)',
                    ),
                    SizedBox(height: 16.h),
                    // 6. Phone Number
                    _buildLabeledTextField(
                      controller: phoneController,
                      label: 'Phone Number (Optional)',
                      keyboardType: TextInputType.phone,
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  if (formKey.currentState?.validate() ?? false) {
                    final updatedEmployee = Employee(
                      name: nameController.text.trim(),
                      monthlySalary: CurrencyInputFormatter.parseAmount(
                          salaryController.text),
                      pointSalary: CurrencyInputFormatter.parseAmount(
                          pointSalaryController.text),
                      adharCard: adharController.text.trim().isEmpty
                          ? null
                          : adharController.text.trim(),
                      location: locationController.text.trim(),
                      residentialAddress:
                          residentialController.text.trim().isEmpty
                              ? null
                              : residentialController.text.trim(),
                      photoPath: selectedPhotoPath,
                      phoneNumber: phoneController.text.trim().isEmpty
                          ? null
                          : phoneController.text.trim(),
                    );
                    EmployeeService().updateEmployee(employee, updatedEmployee);
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content:
                            Text('Updated employee: ${updatedEmployee.name}'),
                        backgroundColor: Colors.green.shade400,
                      ),
                    );
                  }
                },
                child: const Text('Save'),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showEmployeeDetailDialog(BuildContext context, Employee employee) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
        ),
        child: Container(
          width: 0.9.sw, // Acceptable width for ID card feel
          padding: EdgeInsets.all(20.r),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16.r),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Top Section: Horizontal Layout
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Left Side: Image + ID
                  Column(
                    children: [
                      Container(
                        width: 90.r,
                        height: 90.r,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.grey.shade200,
                          border: Border.all(
                            color: AppTheme.primaryColor.withOpacity(0.2),
                            width: 2.w,
                          ),
                        ),
                        child: ClipOval(
                          child: employee.photoPath != null
                              ? Image.file(
                                  File(employee.photoPath!),
                                  fit: BoxFit.cover,
                                  gaplessPlayback: true,
                                  errorBuilder: (context, error, stackTrace) =>
                                      Icon(Icons.person,
                                          size: 50.sp, color: Colors.grey),
                                )
                              : Icon(Icons.person,
                                  size: 50.sp, color: Colors.grey),
                        ),
                      ),
                      SizedBox(height: 8.h),
                    ],
                  ),
                  SizedBox(width: 20.w),
                  // Right Side: Info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          employee.name,
                          style: TextStyle(
                            fontSize: 20.sp,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        SizedBox(height: 12.h),
                        _buildCompactDetailRow(
                            Icons.location_on_outlined,
                            employee.location?.isNotEmpty == true
                                ? employee.location!
                                : 'Point N/A'),
                        SizedBox(height: 8.h),
                        _buildCompactDetailRow(
                            Icons.home_outlined,
                            employee.residentialAddress?.isNotEmpty == true
                                ? employee.residentialAddress!
                                : 'Address N/A'),
                        SizedBox(height: 8.h),
                        _buildCompactDetailRow(
                            Icons.badge_outlined,
                            employee.adharCard?.isNotEmpty == true
                                ? employee.adharCard!
                                : 'Adhar N/A'),
                        SizedBox(height: 8.h),
                        _buildCompactDetailRow(
                            Icons.phone_outlined,
                            employee.phoneNumber?.isNotEmpty == true
                                ? employee.phoneNumber!
                                : 'Phone N/A'),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20.h),
              Divider(color: Colors.grey.shade200),
              SizedBox(height: 12.h),
              // Bottom Section: Salary
              Column(
                children: [
                  Text(
                    'Monthly Salary',
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: AppTheme.textSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    '₹${NumberFormat('#,##0').format(employee.monthlySalary)}',
                    style: TextStyle(
                      fontSize: 28.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.green.shade700,
                    ),
                  ),
                  SizedBox(height: 12.h),
                  Text(
                    'Point Salary: ₹${NumberFormat('#,##0').format(employee.pointSalary)}',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16.h),
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: () => Navigator.pop(context),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.grey.shade600,
                  ),
                  child: const Text('Close'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCompactDetailRow(IconData icon, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16.sp, color: AppTheme.textSecondary),
        SizedBox(width: 8.w),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 14.sp,
              color: AppTheme.textPrimary,
              height: 1.2,
            ),
          ),
        ),
      ],
    );
  }

  void _deleteEmployee(BuildContext context, Employee employee) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Employee'),
        content: Text('Are you sure you want to delete ${employee.name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              EmployeeService().deleteEmployee(employee);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Deleted employee: ${employee.name}'),
                  backgroundColor: Colors.red.shade300,
                ),
              );
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  Widget _buildLabeledTextField({
    required TextEditingController controller,
    required String label,
    String? hint,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    String? Function(String?)? validator,
    bool isNumber = false, // Added parameter
    int maxLines = 1, // Added parameter
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 13.sp, // Reduced font size
            fontWeight: FontWeight.w600,
            color: Colors.black87, // Lighter black
          ),
        ),
        SizedBox(height: 8.h),
        TextFormField(
          controller: controller,
          keyboardType: isNumber ? TextInputType.number : keyboardType,
          inputFormatters:
              isNumber ? [CurrencyInputFormatter()] : inputFormatters,
          maxLines: maxLines,
          style: TextStyle(
              fontSize: 14.sp, color: Colors.black87), // Lighter black
          validator: validator,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
                fontSize: 14.sp, color: Colors.black45), // Lighter hint
            contentPadding:
                EdgeInsets.symmetric(vertical: 12.h, horizontal: 12.w),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.r),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.r),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final employeeService = EmployeeService();

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Employee Management'),
        ),
        drawer: const AppDrawer(),
        body: ListenableBuilder(
          listenable: employeeService,
          builder: (context, child) {
            // Filter employees based on search query
            final allEmployees = employeeService.employees;
            final employees = _searchQuery.isEmpty
                ? allEmployees
                : allEmployees.where((employee) {
                    final query = _searchQuery.toLowerCase();
                    return employee.name.toLowerCase().contains(query);
                  }).toList();

            return SingleChildScrollView(
              padding: EdgeInsets.all(16.0.r),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Employee\nManagement',
                    style: TextStyle(
                        fontSize: 28.sp,
                        fontWeight: FontWeight.bold,
                        height: 1.2),
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    'Manage employee information and default salaries',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  SizedBox(height: 24.h),

                  // Add Employee Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () => _showAddEmployeeDialog(context),
                      icon: const Icon(Icons.add),
                      label: const Text('Add Employee'),
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 12.h),
                      ),
                    ),
                  ),
                  SizedBox(height: 24.h),

                  // Search Bar
                  TextField(
                    onChanged: (value) {
                      setState(() {
                        _searchQuery = value;
                      });
                    },
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.search),
                      hintText: 'Search employees by name or ID',
                      contentPadding: EdgeInsets.symmetric(
                          vertical: 12.h, horizontal: 16.w),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.r),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.r),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                    ),
                  ),
                  SizedBox(height: 24.h),

                  // Employee List
                  if (employees.isEmpty)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(32.0),
                        child: Text('No employees found'),
                      ),
                    )
                  else
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: employees.length,
                      separatorBuilder: (context, index) =>
                          SizedBox(height: 16.h),
                      itemBuilder: (context, index) {
                        final employee = employees[index];
                        return _buildEmployeeCard(context, employee);
                      },
                    ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildEmployeeCard(BuildContext context, Employee employee) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16.0.r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 48.r,
                  height: 48.r,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppTheme.primaryColor,
                  ),
                  child: ClipOval(
                    child: employee.photoPath != null
                        ? Image.file(
                            File(employee.photoPath!),
                            fit: BoxFit.cover,
                            gaplessPlayback: true,
                            errorBuilder: (context, error, stackTrace) {
                              return Icon(Icons.person_outline,
                                  color: Colors.white);
                            },
                          )
                        : Icon(Icons.person_outline, color: Colors.white),
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        employee.name,
                        style: TextStyle(
                            fontSize: 16.sp, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      onPressed: () =>
                          _showEditEmployeeDialog(context, employee),
                      icon: Icon(Icons.edit_outlined,
                          size: 20.sp, color: Colors.grey),
                      tooltip: 'Edit Employee',
                    ),
                    IconButton(
                      onPressed: () => _deleteEmployee(context, employee),
                      icon: Icon(Icons.delete_outline,
                          size: 20.sp, color: Colors.red),
                      tooltip: 'Delete Employee',
                    ),
                  ],
                ),
              ],
            ),
            if (employee.location != null && employee.location!.isNotEmpty)
              Padding(
                padding: EdgeInsets.only(top: 8.h),
                child: Row(
                  children: [
                    Icon(Icons.location_on_outlined,
                        size: 16.sp, color: AppTheme.textSecondary),
                    SizedBox(width: 8.w),
                    Text(
                      employee.location!,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
            SizedBox(height: 12.h),
            Divider(color: Colors.grey.shade100),
            SizedBox(height: 8.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text:
                            '₹${NumberFormat('#,##0').format(employee.monthlySalary)}',
                        style: TextStyle(
                          color: Colors.green.shade700,
                          fontSize: 18.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      TextSpan(
                        text: ' / month',
                        style: TextStyle(
                          color: AppTheme.textSecondary,
                          fontSize: 14.sp,
                        ),
                      ),
                    ],
                  ),
                ),
                TextButton(
                  onPressed: () => _showEmployeeDetailDialog(context, employee),
                  style: TextButton.styleFrom(
                    visualDensity: VisualDensity.compact,
                    foregroundColor: AppTheme.primaryColor,
                  ),
                  child: const Text('View'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
