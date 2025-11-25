class Employee {
  final String? id;
  final String name;
  final String role;
  final double monthlySalary;

  Employee({
    this.id,
    required this.name,
    required this.role,
    required this.monthlySalary,
  });
  factory Employee.fromJson(Map<String, dynamic> json) {
    return Employee(
      id: json['id'],
      name: json['name'],
      role: json['role'],
      monthlySalary: json['monthlySalary'].toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'role': role,
      'monthlySalary': monthlySalary,
    };
  }
}
