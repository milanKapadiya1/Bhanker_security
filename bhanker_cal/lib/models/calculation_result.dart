class CalculationResult {
  final String employeeName;
  final DateTime date;
  final double monthlySalary;
  final double pointSalary; // Added pointSalary field
  final int presentDays;
  final int totalDays;
  final double calculatedSalary;

  final double wc;
  final double uniform;
  final double advance;
  final bool isSaved;

  CalculationResult({
    required this.employeeName,
    required this.date,
    required this.monthlySalary,
    this.pointSalary = 0.0, // Default 0.0 if not provided (migration safe)
    required this.presentDays,
    required this.totalDays,
    required this.calculatedSalary,
    this.wc = 0.0,
    this.uniform = 0.0,
    this.advance = 0.0,
    this.isSaved = false,
  });

  double get perDayAmount => monthlySalary / totalDays;
  double get profit => calculatedSalary - pointSalary; // Profit Calculation

  CalculationResult copyWith({
    String? employeeName,
    DateTime? date,
    double? monthlySalary,
    double? pointSalary,
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
      date: date ?? this.date,
      monthlySalary: monthlySalary ?? this.monthlySalary,
      pointSalary: pointSalary ?? this.pointSalary,
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
      employeeName: json['employeeName'] ?? 'Unknown',
      date: DateTime.tryParse(json['date'] ?? '') ?? DateTime.now(),
      monthlySalary: (json['monthlySalary'] ?? 0).toDouble(),
      pointSalary: (json['pointSalary'] ?? 0).toDouble(), // Handle legacy JSON
      presentDays: json['presentDays'] ?? 0,
      totalDays: json['totalDays'] ?? 0,
      calculatedSalary: (json['calculatedSalary'] ?? 0).toDouble(),
      wc: (json['wc'] ?? 0).toDouble(),
      uniform: (json['uniform'] ?? 0).toDouble(),
      advance: (json['advance'] ?? 0).toDouble(),
      isSaved: json['isSaved'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'employeeName': employeeName,
      'date': date.toIso8601String(),
      'monthlySalary': monthlySalary,
      'pointSalary': pointSalary,
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
