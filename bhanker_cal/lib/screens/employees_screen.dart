import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import '../models/employee.dart';
import '../theme/app_theme.dart';
import '../widgets/app_drawer.dart';

import '../services/employee_service.dart';

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
    return pickedFile?.path;
  }

  void _showAddEmployeeDialog(BuildContext context) {
    final nameController = TextEditingController();
    final roleController = TextEditingController();
    final salaryController = TextEditingController();
    final idController = TextEditingController();
    final adharController = TextEditingController();
    final locationController = TextEditingController();
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
                      child: CircleAvatar(
                        radius: 40.r,
                        backgroundColor: Colors.grey.shade200,
                        backgroundImage: selectedPhotoPath != null
                            ? FileImage(File(selectedPhotoPath!))
                            : null,
                        child: selectedPhotoPath == null
                            ? Icon(Icons.add_a_photo,
                                size: 30.sp, color: Colors.grey.shade600)
                            : null,
                      ),
                    ),
                    SizedBox(height: 24.h),
                    TextFormField(
                      controller: nameController,
                      decoration: const InputDecoration(labelText: 'Name'),
                      validator: (value) =>
                          value?.isEmpty ?? true ? 'Please enter a name' : null,
                    ),
                    TextFormField(
                      controller: roleController,
                      decoration:
                          const InputDecoration(labelText: 'Role (Optional)'),
                    ),
                    TextFormField(
                      controller: salaryController,
                      decoration:
                          const InputDecoration(labelText: 'Monthly Salary'),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a salary';
                        }
                        if (double.tryParse(value) == null) {
                          return 'Please enter a valid number';
                        }
                        return null;
                      },
                    ),
                    TextFormField(
                      controller: idController,
                      decoration: const InputDecoration(
                          labelText: 'Employee ID (Optional)',
                          hintText: 'Leave empty for no ID'),
                    ),
                    TextFormField(
                      controller: adharController,
                      decoration: const InputDecoration(
                          labelText: 'Adhar Card (Optional)',
                          hintText: 'Enter Adhar Card Number'),
                    ),
                    TextFormField(
                      controller: locationController,
                      decoration: const InputDecoration(
                          labelText: 'Location (Optional)',
                          hintText: 'Enter Location'),
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
                      id: idController.text.trim().isEmpty
                          ? null
                          : idController.text.trim(),
                      name: nameController.text.trim(),
                      role: roleController.text.trim(),
                      monthlySalary: double.parse(salaryController.text),
                      adharCard: adharController.text.trim().isEmpty
                          ? null
                          : adharController.text.trim(),
                      location: locationController.text.trim().isEmpty
                          ? null
                          : locationController.text.trim(),
                      photoPath: selectedPhotoPath,
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
    final roleController = TextEditingController(text: employee.role);
    final salaryController =
        TextEditingController(text: employee.monthlySalary.toStringAsFixed(0));
    final idController = TextEditingController(text: employee.id ?? '');
    final adharController =
        TextEditingController(text: employee.adharCard ?? '');
    final locationController =
        TextEditingController(text: employee.location ?? '');
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
                      child: CircleAvatar(
                        radius: 40.r,
                        backgroundColor: Colors.grey.shade200,
                        backgroundImage: selectedPhotoPath != null
                            ? FileImage(File(selectedPhotoPath!))
                            : null,
                        child: selectedPhotoPath == null
                            ? Icon(Icons.add_a_photo,
                                size: 30.sp, color: Colors.grey.shade600)
                            : null,
                      ),
                    ),
                    SizedBox(height: 24.h),
                    _buildLabeledTextField(
                      controller: nameController,
                      label: 'Name',
                      validator: (value) =>
                          value?.isEmpty ?? true ? 'Please enter a name' : null,
                    ),
                    SizedBox(height: 16.h),
                    _buildLabeledTextField(
                      controller: roleController,
                      label: 'Role (Optional)',
                    ),
                    SizedBox(height: 16.h),
                    _buildLabeledTextField(
                      controller: salaryController,
                      label: 'Monthly Salary',
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a salary';
                        }
                        if (double.tryParse(value) == null) {
                          return 'Please enter a valid number';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 16.h),
                    _buildLabeledTextField(
                      controller: idController,
                      label: 'Employee ID (Optional)',
                      hint: 'Leave empty for no ID',
                    ),
                    SizedBox(height: 16.h),
                    _buildLabeledTextField(
                      controller: adharController,
                      label: 'Adhar Card (Optional)',
                      hint: 'Enter Adhar Card Number',
                    ),
                    SizedBox(height: 16.h),
                    _buildLabeledTextField(
                      controller: locationController,
                      label: 'Location (Optional)',
                      hint: 'Enter Location',
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
                      id: idController.text.trim().isEmpty
                          ? null
                          : idController.text.trim(),
                      name: nameController.text.trim(),
                      role: roleController.text.trim(),
                      monthlySalary: double.parse(salaryController.text),
                      adharCard: adharController.text.trim().isEmpty
                          ? null
                          : adharController.text.trim(),
                      location: locationController.text.trim().isEmpty
                          ? null
                          : locationController.text.trim(),
                      photoPath: selectedPhotoPath,
                    );
                    EmployeeService().updateEmployee(employee, updatedEmployee);
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                          content: Text(
                              'Updated employee: ${updatedEmployee.name}')),
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
    String? Function(String?)? validator,
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
          keyboardType: keyboardType,
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
                    return employee.name.toLowerCase().contains(query) ||
                        (employee.id?.toLowerCase().contains(query) ?? false) ||
                        employee.role.toLowerCase().contains(query);
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
                      hintText: 'Search employees by name, ID, or role',
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
                CircleAvatar(
                  radius: 24.r,
                  backgroundColor: AppTheme.primaryColor,
                  backgroundImage: employee.photoPath != null
                      ? FileImage(File(employee.photoPath!))
                      : null,
                  child: employee.photoPath == null
                      ? const Icon(Icons.person_outline, color: Colors.white)
                      : null,
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
                      if (employee.id != null && employee.id!.isNotEmpty)
                        Text(
                          'ID: ${employee.id}',
                          style: Theme.of(context).textTheme.bodySmall,
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
            const SizedBox(height: 16),
            Row(
              children: [
                Icon(Icons.business_outlined,
                    size: 16.sp, color: AppTheme.textSecondary),
                SizedBox(width: 8.w),
                Text(
                  employee.role,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
            const SizedBox(height: 8),
            // Role Badge (e.g., HR) - Hardcoded for now based on image
            if (employee.role.contains('HR'))
              Container(
                margin: EdgeInsets.only(top: 4.h, bottom: 12.h),
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                decoration: BoxDecoration(
                  color: Colors.purple.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4.r),
                ),
                child: Text(
                  'HR',
                  style: TextStyle(
                      fontSize: 10.sp,
                      color: Colors.purple,
                      fontWeight: FontWeight.bold),
                ),
              ),

            if (!employee.role.contains('HR')) SizedBox(height: 12.h),
            Divider(color: Colors.grey.shade100),
            SizedBox(height: 8.h),
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
          ],
        ),
      ),
    );
  }
}
