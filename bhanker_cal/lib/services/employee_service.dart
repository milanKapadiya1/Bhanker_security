import 'package:flutter/material.dart';
import '../models/employee.dart';

class EmployeeService extends ChangeNotifier {
  static final EmployeeService _instance = EmployeeService._internal();

  factory EmployeeService() {
    return _instance;
  }

  EmployeeService._internal();

  final List<Employee> _employees = [
    Employee(
        id: 'EMP001',
        name: 'John Doe',
        role: 'Software Engineer',
        monthlySalary: 50000),
    Employee(
        id: 'EMP002',
        name: 'Sarah Johnson',
        role: 'HR Manager',
        monthlySalary: 4800),
    Employee(
        id: 'EMP003',
        name: 'Michael Davis',
        role: 'Financial Analyst',
        monthlySalary: 4500),
    Employee(
        id: 'EMP004',
        name: 'David Brown',
        role: 'Developer',
        monthlySalary: 5000),
  ];

  List<Employee> get employees => List.unmodifiable(_employees);

  void addEmployee(Employee employee) {
    _employees.add(employee);
    notifyListeners();
  }

  void updateEmployee(Employee oldEmployee, Employee newEmployee) {
    final index = _employees.indexOf(oldEmployee);
    if (index != -1) {
      _employees[index] = newEmployee;
      notifyListeners();
    }
  }

  void deleteEmployee(Employee employee) {
    _employees.remove(employee);
    notifyListeners();
  }

  List<Employee> search(String query) {
    if (query.isEmpty) return [];
    final lowerQuery = query.toLowerCase();
    return _employees.where((employee) {
      return employee.name.toLowerCase().contains(lowerQuery) ||
          (employee.id?.toLowerCase().contains(lowerQuery) ?? false) ||
          employee.role.toLowerCase().contains(lowerQuery);
    }).toList();
  }

  // Helper to find exact match by name
  Employee? findByName(String name) {
    try {
      return _employees
          .firstWhere((e) => e.name.toLowerCase() == name.toLowerCase());
    } catch (e) {
      return null;
    }
  }
}
