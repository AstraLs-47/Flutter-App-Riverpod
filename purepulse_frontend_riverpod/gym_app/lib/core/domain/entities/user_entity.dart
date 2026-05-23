class UserEntity {
  final String id;
  final String name;
  final String email;
  final String role;
  final String bio;

  const UserEntity({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.bio = '',
  });

  UserEntity copyWith({
    String? id,
    String? name,
    String? email,
    String? role,
    String? bio,
  }) {
    return UserEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      role: role ?? this.role,
      bio: bio ?? this.bio,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserEntity && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'UserEntity(id: $id, name: $name, email: $email, role: $role)';
}
