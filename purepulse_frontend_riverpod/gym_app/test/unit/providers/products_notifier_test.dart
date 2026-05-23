import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gym_app/core/domain/repositories/i_product_repository.dart';
import 'package:gym_app/core/models/product_model.dart';
import 'package:gym_app/core/providers/core_providers.dart';
import 'package:gym_app/features/products/presentation/providers/product_providers.dart';
import 'package:mocktail/mocktail.dart';

class MockProductRepository extends Mock implements IProductRepository {}

void main() {
  late MockProductRepository mockProductRepository;

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
  });

  ProviderContainer makeContainer() {
    final container = ProviderContainer(
      overrides: [
        productRepositoryProvider.overrideWithValue(mockProductRepository),
      ],
    );
    addTearDown(container.dispose);
    return container;
  }

  group('ProductsNotifier', () {
    test('loads products correctly from repository use case', () async {
      when(() => mockProductRepository.getProducts(forceRefresh: any(named: 'forceRefresh')))
          .thenAnswer((_) async => [testProduct]);

      final container = makeContainer();
      
      // Wait for build to execute
      await container.read(productsProvider.future);

      final state = container.read(productsProvider);
      expect(state.value, [testProduct]);
    });

    test('adds product and updates state list', () async {
      when(() => mockProductRepository.getProducts(forceRefresh: any(named: 'forceRefresh')))
          .thenAnswer((_) async => []);
      when(() => mockProductRepository.createProduct(any()))
          .thenAnswer((_) async => testProduct);

      final container = makeContainer();
      await container.read(productsProvider.future);

      final notifier = container.read(productsProvider.notifier);
      await notifier.addProduct(testProduct);

      final state = container.read(productsProvider);
      expect(state.value, [testProduct]);
    });
  });
}
