// Project imports:
import '../../../core/models/product_model.dart';
import 'product_repository.dart';

class ProductService {
  final ProductRepository _repo = ProductRepository();

  Future<List<Product>> fetchProducts({bool forceRefresh = false}) async {
    return _repo.getProducts(forceRefresh: forceRefresh);
  }

  Future<void> addProduct(Product product) async {
    await _repo.createProduct(product);
  }

  Future<void> updateProduct(Product product) async {
    await _repo.updateProduct(product);
  }

  Future<void> deleteProduct(String id) async {
    await _repo.deleteProduct(id);
  }
}
