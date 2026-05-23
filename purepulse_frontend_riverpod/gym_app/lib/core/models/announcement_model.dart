class Announcement {
  final String id;
  final String title;
  final String description;
  final String date;

  Announcement({
    required this.id,
    required this.title,
    required this.description,
    required this.date,
  });

  factory Announcement.fromJson(Map<String, dynamic> json) {
    return Announcement(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      date: json['date'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'date': date,
    };
  }

  Announcement copyWith({
    String? id,
    String? title,
    String? description,
    String? date,
  }) {
    return Announcement(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      date: date ?? this.date,
    );
  }
}
