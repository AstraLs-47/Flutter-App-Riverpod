import '../../../core/domain/repositories/i_product_repository.dart';
import '../../../core/models/product_model.dart';

class UpdateProductUseCase {
  final IProductRepository _productRepository;

  UpdateProductUseCase(this._productRepository);

  Future<Product> call(Product product) {
    return _productRepository.updateProduct(product);
  }
}
