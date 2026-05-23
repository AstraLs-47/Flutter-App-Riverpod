import '../../../core/models/product_model.dart';

/// Contract that [ProductRepository] must implement.
abstract interface class IProductRepository {
  Future<List<Product>> getProducts({bool forceRefresh = false});
  Future<Product> createProduct(Product product);
  Future<Product> updateProduct(Product product);
  Future<void> deleteProduct(String id);
}
