class HealthRecordEntity {
  final String id;
  final double systolic;
  final double diastolic;
  final double heartRate;
  final double bloodSugar;
  final double weight;
  final double height;
  final double bmi;
  final DateTime date;

  const HealthRecordEntity({
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

  HealthRecordEntity copyWith({
    String? id,
    double? systolic,
    double? diastolic,
    double? heartRate,
    double? bloodSugar,
    double? weight,
    double? height,
    double? bmi,
    DateTime? date,
  }) {
    return HealthRecordEntity(
      id: id ?? this.id,
      systolic: systolic ?? this.systolic,
      diastolic: diastolic ?? this.diastolic,
      heartRate: heartRate ?? this.heartRate,
      bloodSugar: bloodSugar ?? this.bloodSugar,
      weight: weight ?? this.weight,
      height: height ?? this.height,
      bmi: bmi ?? this.bmi,
      date: date ?? this.date,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HealthRecordEntity && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'HealthRecordEntity(id: $id, weight: $weight, bmi: $bmi)';
}
