class CalculationResult {
  final String employeeName;
  final String employeeId;
  final DateTime date;
  final double monthlySalary;
  final int presentDays;
  final int totalDays;
  final double calculatedSalary;

  CalculationResult({
    required this.employeeName,
    required this.employeeId,
    required this.date,
    required this.monthlySalary,
    required this.presentDays,
    required this.totalDays,
    required this.calculatedSalary,
  });

  double get perDayAmount => monthlySalary / totalDays;
}
