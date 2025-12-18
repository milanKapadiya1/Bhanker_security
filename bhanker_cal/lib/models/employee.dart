class Employee {
  final String? id;
  final String name;
  final String role;
  final double monthlySalary;
  final String? adharCard;
  final String? location;
  final String? photoPath;

  Employee({
    this.id,
    required this.name,
    required this.role,
    required this.monthlySalary,
    this.adharCard,
    this.location,
    this.photoPath,
  });

  factory Employee.fromJson(Map<String, dynamic> json) {
    return Employee(
      id: json['id'],
      name: json['name'],
      role: json['role'],
      monthlySalary: json['monthlySalary'].toDouble(),
      adharCard: json['adharCard'],
      location: json['location'],
      photoPath: json['photoPath'],
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
      'photoPath': photoPath,
    };
  }
}
