// Flutter imports:
import 'package:flutter/material.dart';

class HealthRecord {
  final String id;
  final double systolic;
  final double diastolic;
  final double heartRate;
  final double bloodSugar;
  final double weight;
  final double height;
  final double bmi;
  final DateTime date;

  HealthRecord({
    required this.id,
    required this.systolic,
    required this.diastolic,
    required this.heartRate,
    required this.bloodSugar,
    required this.weight,
    required this.height,
    required this.bmi,
    required this.date,
  });

  factory HealthRecord.fromJson(Map<String, dynamic> json) {
    return HealthRecord(
      id: json['id'],
      systolic: (json['systolic'] as num).toDouble(),
      diastolic: (json['diastolic'] as num).toDouble(),
      heartRate: (json['heartRate'] as num).toDouble(),
      bloodSugar: (json['bloodSugar'] as num).toDouble(),
      weight: (json['weight'] as num).toDouble(),
      height: (json['height'] as num).toDouble(),
      bmi: (json['bmi'] as num).toDouble(),
      date: DateTime.parse(json['date']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'systolic': systolic,
      'diastolic': diastolic,
      'heartRate': heartRate,
      'bloodSugar': bloodSugar,
      'weight': weight,
      'height': height,
      'bmi': bmi,
      'date': date.toIso8601String(),
    };
  }

  String get bmiCategory {
    if (bmi < 18.5) return 'Underweight';
    if (bmi < 25) return 'Normal';
    if (bmi < 30) return 'Overweight';
    return 'Obese';
  }

  Color get bmiColor {
    if (bmi < 18.5) return Colors.orange;
    if (bmi < 25) return Colors.green;
    if (bmi < 30) return Colors.orange;
    return Colors.red;
  }
}
