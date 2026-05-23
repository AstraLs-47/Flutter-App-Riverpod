class ProductEntity {
  final String id;
  final String title;
  final String description;
  final String category;
  final String image;

  const ProductEntity({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.image,
  });

  ProductEntity copyWith({
    String? id,
    String? title,
    String? description,
    String? category,
    String? image,
  }) {
    return ProductEntity(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      image: image ?? this.image,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProductEntity && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'ProductEntity(id: $id, title: $title, category: $category)';
}
