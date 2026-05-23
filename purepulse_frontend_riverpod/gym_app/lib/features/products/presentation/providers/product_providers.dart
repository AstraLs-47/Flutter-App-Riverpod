// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../../../core/models/product_model.dart';
import '../../../../core/providers/core_providers.dart';

class ProductsNotifier extends AsyncNotifier<List<Product>> {
  @override
  Future<List<Product>> build() async {
    final getProductsUseCase = ref.read(getProductsUseCaseProvider);
    return getProductsUseCase.call();
  }

  Future<void> loadProducts({bool forceRefresh = false}) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final getProductsUseCase = ref.read(getProductsUseCaseProvider);
      return getProductsUseCase.call(forceRefresh: forceRefresh);
    });
  }

  Future<void> addProduct(Product product) async {
    final createProductUseCase = ref.read(createProductUseCaseProvider);
    final response = await createProductUseCase.call(product);
    state = AsyncValue.data([...state.value ?? [], response]);
  }

  Future<void> updateProduct(Product product) async {
    final updateProductUseCase = ref.read(updateProductUseCaseProvider);
    final response = await updateProductUseCase.call(product);
    state = AsyncValue.data((state.value ?? []).map((e) => e.id == response.id ? response : e).toList());
  }

  Future<void> deleteProduct(String id) async {
    final deleteProductUseCase = ref.read(deleteProductUseCaseProvider);
    await deleteProductUseCase.call(id);
    state = AsyncValue.data((state.value ?? []).where((e) => e.id != id).toList());
  }
}

// Providers
final productsProvider = AsyncNotifierProvider<ProductsNotifier, List<Product>>(() {
  return ProductsNotifier();
});
