import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/calculation_result.dart';

class SalaryService extends ChangeNotifier {
  static final SalaryService _instance = SalaryService._internal();
  static const String _historyKey = 'salary_history';
  static const String _sessionKey = 'salary_session';

  factory SalaryService() {
    return _instance;
  }

  SalaryService._internal();

  // Permanent History
  Future<List<CalculationResult>> getHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final String? historyJson = prefs.getString(_historyKey);
    if (historyJson == null) return [];
    final List<dynamic> decodedList = jsonDecode(historyJson);
    return decodedList.map((item) => CalculationResult.fromJson(item)).toList();
  }

  Future<void> saveCalculation(CalculationResult result) async {
    final prefs = await SharedPreferences.getInstance();
    final List<CalculationResult> currentHistory = await getHistory();
    currentHistory.insert(0, result); // Add to top
    final String encodedList =
        jsonEncode(currentHistory.map((e) => e.toJson()).toList());
    await prefs.setString(_historyKey, encodedList);
    notifyListeners();
  }

  Future<void> saveBatch(List<CalculationResult> batch) async {
    if (batch.isEmpty) return;
    final prefs = await SharedPreferences.getInstance();
    final List<CalculationResult> currentHistory = await getHistory();
    // Insert batch at the top
    currentHistory.insertAll(0, batch);
    final String encodedList =
        jsonEncode(currentHistory.map((e) => e.toJson()).toList());
    await prefs.setString(_historyKey, encodedList);
    notifyListeners();
  }

  // Session History (Calculator Screen)
  Future<List<CalculationResult>> getSession() async {
    final prefs = await SharedPreferences.getInstance();
    final String? sessionJson = prefs.getString(_sessionKey);
    if (sessionJson == null) return [];
    final List<dynamic> decodedList = jsonDecode(sessionJson);
    return decodedList.map((item) => CalculationResult.fromJson(item)).toList();
  }

  Future<void> saveSession(List<CalculationResult> session) async {
    final prefs = await SharedPreferences.getInstance();
    final String encodedList =
        jsonEncode(session.map((e) => e.toJson()).toList());
    await prefs.setString(_sessionKey, encodedList);
  }

  Future<void> clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_sessionKey);
  }
}
