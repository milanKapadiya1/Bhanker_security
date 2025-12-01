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
  final bool isSaved;

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
    this.isSaved = false,
  });

  double get perDayAmount => monthlySalary / totalDays;

  CalculationResult copyWith({
    String? employeeName,
    String? employeeId,
    String? employeeRole,
    DateTime? date,
    double? monthlySalary,
    int? presentDays,
    int? totalDays,
    double? calculatedSalary,
    double? wc,
    double? uniform,
    double? advance,
    bool? isSaved,
  }) {
    return CalculationResult(
      employeeName: employeeName ?? this.employeeName,
      employeeId: employeeId ?? this.employeeId,
      employeeRole: employeeRole ?? this.employeeRole,
      date: date ?? this.date,
      monthlySalary: monthlySalary ?? this.monthlySalary,
      presentDays: presentDays ?? this.presentDays,
      totalDays: totalDays ?? this.totalDays,
      calculatedSalary: calculatedSalary ?? this.calculatedSalary,
      wc: wc ?? this.wc,
      uniform: uniform ?? this.uniform,
      advance: advance ?? this.advance,
      isSaved: isSaved ?? this.isSaved,
    );
  }

  factory CalculationResult.fromJson(Map<String, dynamic> json) {
    return CalculationResult(
      employeeName: json['employeeName'],
      employeeId: json['employeeId'],
      employeeRole: json['employeeRole'] ?? 'Employee',
      date: DateTime.parse(json['date']),
      monthlySalary: json['monthlySalary'].toDouble(),
      presentDays: json['presentDays'],
      totalDays: json['totalDays'],
      calculatedSalary: json['calculatedSalary'].toDouble(),
      wc: (json['wc'] ?? 0.0).toDouble(),
      uniform: (json['uniform'] ?? 0.0).toDouble(),
      advance: (json['advance'] ?? 0.0).toDouble(),
      isSaved: json['isSaved'] ?? false,
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
      'isSaved': isSaved,
    };
  }
}
