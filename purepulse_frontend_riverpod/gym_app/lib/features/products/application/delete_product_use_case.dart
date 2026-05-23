import '../../../core/domain/repositories/i_product_repository.dart';

class DeleteProductUseCase {
  final IProductRepository _productRepository;

  DeleteProductUseCase(this._productRepository);

  Future<void> call(String id) {
    return _productRepository.deleteProduct(id);
  }
}
