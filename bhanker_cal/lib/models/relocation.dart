import 'package:flutter/material.dart';

class Relocation {
  final String id;
  final String guardId;
  final String guardName;
  final String originalLocation;
  final String newLocation;
  final DateTime date;
  final TimeOfDay startTime;
  final TimeOfDay endTime;
  final double totalHours;
  final double earnedAmount;

  Relocation({
    required this.id,
    required this.guardId,
    required this.guardName,
    required this.originalLocation,
    required this.newLocation,
    required this.date,
    required this.startTime,
    required this.endTime,
    required this.totalHours,
    required this.earnedAmount,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'guardId': guardId,
      'guardName': guardName,
      'originalLocation': originalLocation,
      'newLocation': newLocation,
      'date': date.toIso8601String(),
      'startTime': '${startTime.hour}:${startTime.minute}',
      'endTime': '${endTime.hour}:${endTime.minute}',
      'totalHours': totalHours,
      'earnedAmount': earnedAmount,
    };
  }

  factory Relocation.fromJson(Map<String, dynamic> json) {
    final startTimeParts = (json['startTime'] as String).split(':');
    final endTimeParts = (json['endTime'] as String).split(':');

    return Relocation(
      id: json['id'],
      guardId: json['guardId'],
      guardName: json['guardName'],
      originalLocation: json['originalLocation'],
      newLocation: json['newLocation'],
      date: DateTime.parse(json['date']),
      startTime: TimeOfDay(
          hour: int.parse(startTimeParts[0]),
          minute: int.parse(startTimeParts[1])),
      endTime: TimeOfDay(
          hour: int.parse(endTimeParts[0]), minute: int.parse(endTimeParts[1])),
      totalHours: json['totalHours'],
      earnedAmount: json['earnedAmount'],
    );
  }
}
