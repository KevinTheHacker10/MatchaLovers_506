import 'package:matcha_lovers_506/core/constants.dart';

/// Product entity - Domain layer
class ProductEntity {
  final String id;
  final String name;
  final double price;
  final ProductCategory category;
  final String? description;
  final bool isAvailable;
  final DateTime createdAt;
  final DateTime updatedAt;

  const ProductEntity({
    required this.id,
    required this.name,
    required this.price,
    required this.category,
    this.description,
    this.isAvailable = true,
    required this.createdAt,
    required this.updatedAt,
  });

  ProductEntity copyWith({
    String? id,
    String? name,
    double? price,
    ProductCategory? category,
    String? description,
    bool? isAvailable,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ProductEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      price: price ?? this.price,
      category: category ?? this.category,
      description: description ?? this.description,
      isAvailable: isAvailable ?? this.isAvailable,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
