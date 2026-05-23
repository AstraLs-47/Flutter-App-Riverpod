import '../../../core/domain/repositories/i_product_repository.dart';
import '../../../core/models/product_model.dart';

class CreateProductUseCase {
  final IProductRepository _productRepository;

  CreateProductUseCase(this._productRepository);

  Future<Product> call(Product product) {
    return _productRepository.createProduct(product);
  }
}
