class WorkoutEntry {
  final String id;
  final String title;
  final String date;
  final String duration;
  final String exercise;
  final String intensity;
  final String weight;
  final String sets;
  final String reps;
  final String? calories; // optional
  final String? achievement; // optional
  final String? notes; // optional

  WorkoutEntry({
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

  factory WorkoutEntry.fromJson(Map<String, dynamic> json) {
    return WorkoutEntry(
      id: json['id'],
      title: json['title'],
      date: json['date'],
      duration: json['duration'],
      exercise: json['exercise'],
      intensity: json['intensity'],
      weight: json['weight'],
      sets: json['sets'],
      reps: json['reps'],
      calories: json['calories'],
      achievement: json['achievement'],
      notes: json['notes'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'date': date,
      'duration': duration,
      'exercise': exercise,
      'intensity': intensity,
      'weight': weight,
      'sets': sets,
      'reps': reps,
      'calories': calories,
      'achievement': achievement,
      'notes': notes,
    };
  }
}
