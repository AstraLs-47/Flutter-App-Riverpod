class ExerciseEntity {
  final String id;
  final String title;
  final String description;
  final String category;
  final String image;
  final String duration;
  final String warmup;
  final String mainWorkout;
  final String rest;
  final String? categoryId;

  const ExerciseEntity({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.image,
    this.duration = '',
    this.warmup = '',
    this.mainWorkout = '',
    this.rest = '',
    this.categoryId,
  });

  ExerciseEntity copyWith({
    String? id,
    String? title,
    String? description,
    String? category,
    String? image,
    String? duration,
    String? warmup,
    String? mainWorkout,
    String? rest,
    String? categoryId,
  }) {
    return ExerciseEntity(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      image: image ?? this.image,
      duration: duration ?? this.duration,
      warmup: warmup ?? this.warmup,
      mainWorkout: mainWorkout ?? this.mainWorkout,
      rest: rest ?? this.rest,
      categoryId: categoryId ?? this.categoryId,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ExerciseEntity && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'ExerciseEntity(id: $id, title: $title, category: $category)';
}
