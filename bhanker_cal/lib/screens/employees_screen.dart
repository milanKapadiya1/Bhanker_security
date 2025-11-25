import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
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

  void _showAddEmployeeDialog(BuildContext context) {
    final nameController = TextEditingController();
    final roleController = TextEditingController();
    final salaryController = TextEditingController();
    final idController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add New Employee'),
        content: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Name'),
                  validator: (value) =>
                      value?.isEmpty ?? true ? 'Please enter a name' : null,
                ),
                TextFormField(
                  controller: roleController,
                  decoration: const InputDecoration(labelText: 'Role'),
                  validator: (value) =>
                      value?.isEmpty ?? true ? 'Please enter a role' : null,
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
      ),
    );
  }

  void _showEditEmployeeDialog(BuildContext context, Employee employee) {
    final nameController = TextEditingController(text: employee.name);
    final roleController = TextEditingController(text: employee.role);
    final salaryController =
        TextEditingController(text: employee.monthlySalary.toStringAsFixed(0));
    final idController = TextEditingController(text: employee.id ?? '');
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Employee'),
        content: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Name'),
                  validator: (value) =>
                      value?.isEmpty ?? true ? 'Please enter a name' : null,
                ),
                TextFormField(
                  controller: roleController,
                  decoration: const InputDecoration(labelText: 'Role'),
                  validator: (value) =>
                      value?.isEmpty ?? true ? 'Please enter a role' : null,
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
                );
                EmployeeService().updateEmployee(employee, updatedEmployee);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                      content:
                          Text('Updated employee: ${updatedEmployee.name}')),
                );
              }
            },
            child: const Text('Save'),
          ),
        ],
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

  @override
  Widget build(BuildContext context) {
    final employeeService = EmployeeService();

    return Scaffold(
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
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Employee\nManagement',
                  style: TextStyle(
                      fontSize: 28, fontWeight: FontWeight.bold, height: 1.2),
                ),
                const SizedBox(height: 8),
                Text(
                  'Manage employee information and default salaries',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 24),

                // Add Employee Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => _showAddEmployeeDialog(context),
                    icon: const Icon(Icons.add),
                    label: const Text('Add Employee'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(height: 24),

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
                    contentPadding: const EdgeInsets.symmetric(
                        vertical: 12, horizontal: 16),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                  ),
                ),
                const SizedBox(height: 24),

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
                        const SizedBox(height: 16),
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
    );
  }

  Widget _buildEmployeeCard(BuildContext context, Employee employee) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: AppTheme.primaryColor,
                  child: const Icon(Icons.person_outline, color: Colors.white),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        employee.name,
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
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
                      icon: const Icon(Icons.edit_outlined,
                          size: 20, color: Colors.grey),
                      tooltip: 'Edit Employee',
                    ),
                    IconButton(
                      onPressed: () => _deleteEmployee(context, employee),
                      icon: const Icon(Icons.delete_outline,
                          size: 20, color: Colors.red),
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
                    size: 16, color: AppTheme.textSecondary),
                const SizedBox(width: 8),
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
                margin: const EdgeInsets.only(top: 4, bottom: 12),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.purple.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text(
                  'HR',
                  style: TextStyle(
                      fontSize: 10,
                      color: Colors.purple,
                      fontWeight: FontWeight.bold),
                ),
              ),

            if (!employee.role.contains('HR')) const SizedBox(height: 12),

            Divider(color: Colors.grey.shade100),
            const SizedBox(height: 8),
            RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text:
                        '₹${NumberFormat('#,##0').format(employee.monthlySalary)}',
                    style: TextStyle(
                      color: Colors.green.shade700,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextSpan(
                    text: ' / month',
                    style: TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 14,
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
