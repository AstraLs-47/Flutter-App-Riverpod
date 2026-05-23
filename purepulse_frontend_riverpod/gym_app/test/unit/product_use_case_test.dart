import 'package:flutter_test/flutter_test.dart';
import 'package:gym_app/core/domain/repositories/i_product_repository.dart';
import 'package:gym_app/core/models/product_model.dart';
import 'package:gym_app/features/products/application/get_products_use_case.dart';
import 'package:gym_app/features/products/application/create_product_use_case.dart';
import 'package:gym_app/features/products/application/update_product_use_case.dart';
import 'package:gym_app/features/products/application/delete_product_use_case.dart';
import 'package:mocktail/mocktail.dart';

class MockProductRepository extends Mock implements IProductRepository {}

void main() {
  late MockProductRepository mockProductRepository;
  late GetProductsUseCase getProductsUseCase;
  late CreateProductUseCase createProductUseCase;
  late UpdateProductUseCase updateProductUseCase;
  late DeleteProductUseCase deleteProductUseCase;

  final testProduct = Product(
    id: '1',
    title: 'Protein Powder',
    description: 'Whey protein isolate',
    category: 'Supplements',
    image: 'protein.png',
  );

  setUpAll(() {
    registerFallbackValue(Product(
      id: '',
      title: '',
      description: '',
      category: '',
      image: '',
    ));
  });

  setUp(() {
    mockProductRepository = MockProductRepository();
    getProductsUseCase = GetProductsUseCase(mockProductRepository);
    createProductUseCase = CreateProductUseCase(mockProductRepository);
    updateProductUseCase = UpdateProductUseCase(mockProductRepository);
    deleteProductUseCase = DeleteProductUseCase(mockProductRepository);
  });

  group('GetProductsUseCase', () {
    test('should return list of products from repository', () async {
      when(() => mockProductRepository.getProducts(forceRefresh: any(named: 'forceRefresh')))
          .thenAnswer((_) async => [testProduct]);

      final result = await getProductsUseCase.call(forceRefresh: true);

      expect(result, [testProduct]);
      verify(() => mockProductRepository.getProducts(forceRefresh: true)).called(1);
    });
  });

  group('CreateProductUseCase', () {
    test('should return created product from repository', () async {
      when(() => mockProductRepository.createProduct(any()))
          .thenAnswer((_) async => testProduct);

      final result = await createProductUseCase.call(testProduct);

      expect(result, testProduct);
      verify(() => mockProductRepository.createProduct(testProduct)).called(1);
    });
  });

  group('UpdateProductUseCase', () {
    test('should return updated product from repository', () async {
      when(() => mockProductRepository.updateProduct(any()))
          .thenAnswer((_) async => testProduct);

      final result = await updateProductUseCase.call(testProduct);

      expect(result, testProduct);
      verify(() => mockProductRepository.updateProduct(testProduct)).called(1);
    });
  });

  group('DeleteProductUseCase', () {
    test('should complete successfully when repository delete succeeds', () async {
      when(() => mockProductRepository.deleteProduct(any()))
          .thenAnswer((_) async {});

      await deleteProductUseCase.call('1');

      verify(() => mockProductRepository.deleteProduct('1')).called(1);
    });
  });
}
