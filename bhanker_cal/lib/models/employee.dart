class Employee {
  final String? id;
  final String name;
  final String role;
  final double monthlySalary;
  final String? adharCard;
  final String? location;

  Employee({
    this.id,
    required this.name,
    required this.role,
    required this.monthlySalary,
    this.adharCard,
    this.location,
  });

  factory Employee.fromJson(Map<String, dynamic> json) {
    return Employee(
      id: json['id'],
      name: json['name'],
      role: json['role'],
      monthlySalary: json['monthlySalary'].toDouble(),
      adharCard: json['adharCard'],
      location: json['location'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'role': role,
      'monthlySalary': monthlySalary,
      'adharCard': adharCard,
      'location': location,
    };
  }
}
