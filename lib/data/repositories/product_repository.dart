import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import 'package:matcha_lovers_506/core/constants.dart';
import 'package:matcha_lovers_506/data/models/product_model.dart';
import 'package:matcha_lovers_506/domain/entities/product_entity.dart';

/// Repository for product operations
class ProductRepository {
  final SharedPreferences _prefs;
  static const _uuid = Uuid();

  ProductRepository(this._prefs);

  /// Initialize with sample products
  Future<void> initializeSampleData() async {
    final products = await getAllProducts();
    if (products.isEmpty) {
      final now = DateTime.now();
      final sampleProducts = [
        // Matcha
        _createProduct('Latte', 2800, ProductCategory.matcha, now),
        _createProduct('Taro', 3000, ProductCategory.matcha, now),
        _createProduct('Arándanos', 3000, ProductCategory.matcha, now),
        _createProduct('Mango', 3000, ProductCategory.matcha, now),
        _createProduct('Maracuyá', 3000, ProductCategory.matcha, now),
        _createProduct('Fresa', 3000, ProductCategory.matcha, now),
        _createProduct('Fresas Cremosas', 3500, ProductCategory.matcha, now),
        _createProduct('Piña Colada', 3500, ProductCategory.matcha, now),
        _createProduct('Agua de Pipa', 3000, ProductCategory.matcha, now),
        _createProduct('Pistacho', 3500, ProductCategory.matcha, now),
        _createProduct('Espresso', 3000, ProductCategory.matcha, now),
        _createProduct('Limonada de Coco', 3000, ProductCategory.matcha, now),
        _createProduct('Fresa Mango', 3500, ProductCategory.matcha, now),
        _createProduct('Banano', 3500, ProductCategory.matcha, now),
        _createProduct('Galleta Oreo', 3500, ProductCategory.matcha, now),
        _createProduct('Chocolate', 3000, ProductCategory.matcha, now),
        _createProduct('Caramelo', 3000, ProductCategory.matcha, now),
        _createProduct('Galleta María', 3000, ProductCategory.matcha, now),
        
        // Batidos
        _createProduct('Mango - Maracuyá - Naranja', 2700, ProductCategory.smoothies, now),
        _createProduct('Fresa - Mora - Arándanos', 2700, ProductCategory.smoothies, now),
        _createProduct('Mango - Naranja - Melocotón', 2700, ProductCategory.smoothies, now),
        _createProduct('Piña Colada y Fresa', 3000, ProductCategory.smoothies, now),
        _createProduct('Frutas con agua', 2000, ProductCategory.smoothies, now),
        _createProduct('Frutas con leche', 2700, ProductCategory.smoothies, now),
        
        // Jugos Saludables
        _createProduct('Detox', 2500, ProductCategory.healthyJuices, now, 
            description: 'Piña, apio, pepino, naranja'),
        _createProduct('Pérdida de Peso', 2500, ProductCategory.healthyJuices, now,
            description: 'Piña, mango, espinaca, chía'),
        _createProduct('Anti Estreñimiento', 2500, ProductCategory.healthyJuices, now,
            description: 'Papaya, piña, apio, chía'),
        
        // Cafés Fríos
        _createProduct('Frozen Capuccino', 2800, ProductCategory.coldCoffee, now),
        _createProduct('Fresa Coffee', 3200, ProductCategory.coldCoffee, now),
        _createProduct('Oreo Coffee', 3200, ProductCategory.coldCoffee, now),
        _createProduct('Caramel Macchiato', 3200, ProductCategory.coldCoffee, now),
      ];
      
      for (var product in sampleProducts) {
        await _saveProduct(product);
      }
      debugPrint('Sample products initialized: ${sampleProducts.length} products');
    }
  }

  ProductModel _createProduct(
    String name,
    double price,
    ProductCategory category,
    DateTime now, {
    String? description,
  }) {
    return ProductModel(
      id: _uuid.v4(),
      name: name,
      price: price,
      category: category,
      description: description,
      isAvailable: true,
      createdAt: now,
      updatedAt: now,
    );
  }

  /// Get all products
  Future<List<ProductModel>> getAllProducts() async {
    try {
      final productsJson = _prefs.getStringList(AppConstants.storageKeyProducts) ?? [];
      return productsJson
          .map((json) => ProductModel.fromJson(jsonDecode(json) as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint('Get all products error: $e');
      return [];
    }
  }

  /// Get products by category
  Future<List<ProductEntity>> getProductsByCategory(ProductCategory category) async {
    final products = await getAllProducts();
    return products.where((p) => p.category == category).toList();
  }

  /// Save product
  Future<void> _saveProduct(ProductModel product) async {
    try {
      final products = await getAllProducts();
      products.add(product);
      
      final productsJson = products.map((p) => jsonEncode(p.toJson())).toList();
      await _prefs.setStringList(AppConstants.storageKeyProducts, productsJson);
    } catch (e) {
      debugPrint('Save product error: $e');
    }
  }

  /// Create new product
  Future<ProductEntity?> createProduct({
    required String name,
    required double price,
    required ProductCategory category,
    String? description,
  }) async {
    try {
      final now = DateTime.now();
      final product = ProductModel(
        id: _uuid.v4(),
        name: name,
        price: price,
        category: category,
        description: description,
        isAvailable: true,
        createdAt: now,
        updatedAt: now,
      );
      
      await _saveProduct(product);
      return product;
    } catch (e) {
      debugPrint('Create product error: $e');
      return null;
    }
  }

  /// Update product
  Future<void> updateProduct(ProductEntity product) async {
    try {
      final products = await getAllProducts();
      final index = products.indexWhere((p) => p.id == product.id);
      
      if (index != -1) {
        products[index] = ProductModel.fromEntity(product);
        final productsJson = products.map((p) => jsonEncode(p.toJson())).toList();
        await _prefs.setStringList(AppConstants.storageKeyProducts, productsJson);
      }
    } catch (e) {
      debugPrint('Update product error: $e');
    }
  }

  /// Delete product
  Future<void> deleteProduct(String productId) async {
    try {
      final products = await getAllProducts();
      products.removeWhere((p) => p.id == productId);
      
      final productsJson = products.map((p) => jsonEncode(p.toJson())).toList();
      await _prefs.setStringList(AppConstants.storageKeyProducts, productsJson);
    } catch (e) {
      debugPrint('Delete product error: $e');
    }
  }
}
