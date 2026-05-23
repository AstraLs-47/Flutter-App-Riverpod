class User {
  final String id;
  final String name;
  final String email;
  final String? profileImage;
  final String? bio;

  User({
    required this.id,
    required this.name,
    required this.email,
    this.profileImage,
    this.bio,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      profileImage: json['profileImage'],
      bio: json['bio'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'profileImage': profileImage,
      'bio': bio,
    };
  }
}
