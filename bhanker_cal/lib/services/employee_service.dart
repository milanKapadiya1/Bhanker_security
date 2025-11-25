import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/employee.dart';

class EmployeeService extends ChangeNotifier {
  static final EmployeeService _instance = EmployeeService._internal();
  static const String _storageKey = 'employees_data';

  factory EmployeeService() {
    return _instance;
  }

  EmployeeService._internal() {
    _loadEmployees();
  }

  List<Employee> _employees = [];

  List<Employee> get employees => List.unmodifiable(_employees);

  Future<void> _loadEmployees() async {
    final prefs = await SharedPreferences.getInstance();
    final String? employeesJson = prefs.getString(_storageKey);

    if (employeesJson != null) {
      final List<dynamic> decodedList = jsonDecode(employeesJson);
      _employees = decodedList.map((item) => Employee.fromJson(item)).toList();
      notifyListeners();
    }
  }

  Future<void> _saveEmployees() async {
    final prefs = await SharedPreferences.getInstance();
    final String encodedList =
        jsonEncode(_employees.map((e) => e.toJson()).toList());
    await prefs.setString(_storageKey, encodedList);
  }

  Future<void> addEmployee(Employee employee) async {
    _employees.add(employee);
    notifyListeners();
    await _saveEmployees();
  }

  Future<void> updateEmployee(
      Employee oldEmployee, Employee newEmployee) async {
    final index = _employees.indexOf(oldEmployee);
    if (index != -1) {
      _employees[index] = newEmployee;
      notifyListeners();
      await _saveEmployees();
    }
  }

  Future<void> deleteEmployee(Employee employee) async {
    _employees.remove(employee);
    notifyListeners();
    await _saveEmployees();
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
