class AnnouncementEntity {
  final String id;
  final String title;
  final String description;
  final String date;

  const AnnouncementEntity({
    required this.id,
    required this.title,
    required this.description,
    required this.date,
  });

  AnnouncementEntity copyWith({
    String? id,
    String? title,
    String? description,
    String? date,
  }) {
    return AnnouncementEntity(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      date: date ?? this.date,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AnnouncementEntity && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'AnnouncementEntity(id: $id, title: $title)';
}
