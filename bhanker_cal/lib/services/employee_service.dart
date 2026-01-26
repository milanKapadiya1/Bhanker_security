import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/employee.dart';
import '../models/relocation.dart';

class EmployeeService extends ChangeNotifier {
  static final EmployeeService _instance = EmployeeService._internal();
  static const String _storageKey = 'employees_data';
  static const String _relocationStorageKey = 'relocations_data';

  factory EmployeeService() {
    return _instance;
  }

  EmployeeService._internal() {
    _loadEmployees();
    _loadRelocations();
  }

  List<Employee> _employees = [];
  List<Relocation> _relocations = [];

  List<Employee> get employees => List.unmodifiable(_employees);
  List<Relocation> get relocations => List.unmodifiable(_relocations);

  Future<void> _loadEmployees() async {
    final prefs = await SharedPreferences.getInstance();
    final String? employeesJson = prefs.getString(_storageKey);

    if (employeesJson != null) {
      final List<dynamic> decodedList = jsonDecode(employeesJson);
      _employees = decodedList.map((item) => Employee.fromJson(item)).toList();
      notifyListeners();
    }
  }

  Future<void> _loadRelocations() async {
    final prefs = await SharedPreferences.getInstance();
    final String? relocationsJson = prefs.getString(_relocationStorageKey);

    if (relocationsJson != null) {
      final List<dynamic> decodedList = jsonDecode(relocationsJson);
      _relocations =
          decodedList.map((item) => Relocation.fromJson(item)).toList();
      notifyListeners();
    }
  }

  Future<void> _saveEmployees() async {
    final prefs = await SharedPreferences.getInstance();
    final String encodedList =
        jsonEncode(_employees.map((e) => e.toJson()).toList());
    await prefs.setString(_storageKey, encodedList);
  }

  Future<void> _saveRelocations() async {
    final prefs = await SharedPreferences.getInstance();
    final String encodedList =
        jsonEncode(_relocations.map((e) => e.toJson()).toList());
    await prefs.setString(_relocationStorageKey, encodedList);
  }

  Future<void> addEmployee(Employee employee) async {
    _employees.add(employee);
    notifyListeners();
    await _saveEmployees();
  }

  Future<void> addRelocation(Relocation relocation) async {
    _relocations.add(relocation);
    notifyListeners();
    await _saveRelocations();
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
      return employee.name.toLowerCase().contains(lowerQuery);
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
