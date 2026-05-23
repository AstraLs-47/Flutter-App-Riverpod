import '../../../core/domain/repositories/i_product_repository.dart';
import '../../../core/models/product_model.dart';

class GetProductsUseCase {
  final IProductRepository _productRepository;

  GetProductsUseCase(this._productRepository);

  Future<List<Product>> call({bool forceRefresh = false}) {
    return _productRepository.getProducts(forceRefresh: forceRefresh);
  }
}
