class CalculationResult {
  final String employeeName;
  final String employeeId;
  final String employeeRole; // New field
  final DateTime date;
  final double monthlySalary;
  final int presentDays;
  final int totalDays;
  final double calculatedSalary;

  final double wc;
  final double uniform;
  final double advance;

  CalculationResult({
    required this.employeeName,
    required this.employeeId,
    required this.employeeRole,
    required this.date,
    required this.monthlySalary,
    required this.presentDays,
    required this.totalDays,
    required this.calculatedSalary,
    this.wc = 0.0,
    this.uniform = 0.0,
    this.advance = 0.0,
  });

  double get perDayAmount => monthlySalary / totalDays;

  factory CalculationResult.fromJson(Map<String, dynamic> json) {
    return CalculationResult(
      employeeName: json['employeeName'],
      employeeId: json['employeeId'],
      employeeRole: json['employeeRole'] ??
          'Employee', // Default for backward compatibility
      date: DateTime.parse(json['date']),
      monthlySalary: json['monthlySalary'].toDouble(),
      presentDays: json['presentDays'],
      totalDays: json['totalDays'],
      calculatedSalary: json['calculatedSalary'].toDouble(),
      wc: (json['wc'] ?? 0.0).toDouble(),
      uniform: (json['uniform'] ?? 0.0).toDouble(),
      advance: (json['advance'] ?? 0.0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'employeeName': employeeName,
      'employeeId': employeeId,
      'employeeRole': employeeRole,
      'date': date.toIso8601String(),
      'monthlySalary': monthlySalary,
      'presentDays': presentDays,
      'totalDays': totalDays,
      'calculatedSalary': calculatedSalary,
      'wc': wc,
      'uniform': uniform,
      'advance': advance,
    };
  }
}
