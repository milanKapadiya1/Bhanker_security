class Employee {
  final String name;
  final double monthlySalary;
  final String? adharCard;
  final String? location;
  final String? photoPath;
  final String? residentialAddress;
  final String? phoneNumber;
  final double pointSalary;

  Employee({
    required this.name,
    required this.monthlySalary,
    this.adharCard,
    this.location,
    this.photoPath,
    this.residentialAddress,
    this.phoneNumber,
    // actually user said required. But for existing data?
    // If I make it required without default, existing JSONs might break if I don't handle it in fromJson.
    // Let's make it required in constructor but handle null in fromJson.
    required this.pointSalary,
  });

  factory Employee.fromJson(Map<String, dynamic> json) {
    return Employee(
      name: json['name'],
      monthlySalary: json['monthlySalary'].toDouble(),
      adharCard: json['adharCard'],
      location: json['location'],
      photoPath: json['photoPath'],
      residentialAddress: json['residentialAddress'],
      phoneNumber: json['phoneNumber'],
      pointSalary: (json['pointSalary'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'monthlySalary': monthlySalary,
      'adharCard': adharCard,
      'location': location,
      'photoPath': photoPath,
      'residentialAddress': residentialAddress,
      'phoneNumber': phoneNumber,
      'pointSalary': pointSalary,
    };
  }
}
