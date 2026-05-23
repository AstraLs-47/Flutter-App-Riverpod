class WorkoutEntity {
  final String id;
  final String title;
  final String date;
  final String duration;
  final String exercise;
  final String intensity;
  final String weight;
  final String sets;
  final String reps;
  final String? calories;
  final String? achievement;
  final String? notes;

  const WorkoutEntity({
    required this.id,
    required this.title,
    required this.date,
    required this.duration,
    required this.exercise,
    required this.intensity,
    required this.weight,
    required this.sets,
    required this.reps,
    this.calories,
    this.achievement,
    this.notes,
  });

  WorkoutEntity copyWith({
    String? id,
    String? title,
    String? date,
    String? duration,
    String? exercise,
    String? intensity,
    String? weight,
    String? sets,
    String? reps,
    String? calories,
    String? achievement,
    String? notes,
  }) {
    return WorkoutEntity(
      id: id ?? this.id,
      title: title ?? this.title,
      date: date ?? this.date,
      duration: duration ?? this.duration,
      exercise: exercise ?? this.exercise,
      intensity: intensity ?? this.intensity,
      weight: weight ?? this.weight,
      sets: sets ?? this.sets,
      reps: reps ?? this.reps,
      calories: calories ?? this.calories,
      achievement: achievement ?? this.achievement,
      notes: notes ?? this.notes,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WorkoutEntity && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'WorkoutEntity(id: $id, title: $title, date: $date)';
}
