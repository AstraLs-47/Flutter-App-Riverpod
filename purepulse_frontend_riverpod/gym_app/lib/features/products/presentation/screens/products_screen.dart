// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:go_router/go_router.dart';

// Project imports:
import '../../../../core/constants/route_constants.dart';
import '../../../../core/models/product_model.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/image_utils.dart';
import '../../../../core/utils/navigation_helper.dart';
import '../../../../core/widgets/user_bottom_nav.dart';
import '../../../admin/data/admin_repository.dart';
import '../../data/product_service.dart';

class ProductsScreen extends StatefulWidget {
  const ProductsScreen({super.key});

  @override
  State<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen> {
  final ProductService _productService = ProductService();
  String _selectedCategory = 'All';
  List<String> get _categories => [
    'All',
    ...AdminRepository().productCategories,
  ];
  late Future<List<Product>> _productsFuture;

  @override
  void initState() {
    super.initState();
    _productsFuture = _productService.fetchProducts();
    AdminRepository().fetchCategories();
  }

  List<Product> _filterProducts(List<Product> products) {
    if (_selectedCategory == 'All') return products;
    return products.where((p) {
      final cat = p.category.toUpperCase();
      return cat.contains(_selectedCategory.toUpperCase());
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Product',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const Text(
                    'Arena',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0E6CF2),
                    ),
                  ),
                ],
              ),
            ),

            // Categories
            SizedBox(
              height: 48,
              child: ScrollConfiguration(
                behavior: ScrollConfiguration.of(
                  context,
                ).copyWith(scrollbars: false),
                child: ListView.builder(
                  physics: const BouncingScrollPhysics(),
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: _categories.length,
                  itemBuilder: (context, index) {
                    final cat = _categories[index];
                    final isSelected = _selectedCategory == cat;
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 6),
                      child: GestureDetector(
                        onTap: () => setState(() => _selectedCategory = cat),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? const Color(0xFF0E6CF2)
                                : const Color(0xFFF1F5F9),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Center(
                            child: Text(
                              cat,
                              style: TextStyle(
                                color: isSelected
                                    ? Colors.white
                                    : const Color(0xFF64748B),
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Product Grid with FutureBuilder
            Expanded(
              child: FutureBuilder<List<Product>>(
                future: _productsFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFF0E6CF2),
                      ),
                    );
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(
                      child: Text(
                        'No products found',
                        style: TextStyle(color: AppColors.textSecondary),
                      ),
                    );
                  }

                  final filteredProducts = _filterProducts(snapshot.data!);

                  return ScrollConfiguration(
                    behavior: ScrollConfiguration.of(
                      context,
                    ).copyWith(scrollbars: false),
                    child: filteredProducts.isEmpty
                        ? const Center(
                            child: Text(
                              'No products found in this category',
                              style: TextStyle(color: AppColors.textSecondary),
                            ),
                          )
                        : GridView.builder(
                            physics: const BouncingScrollPhysics(),
                            padding: const EdgeInsets.fromLTRB(24, 0, 24, 80),
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2,
                                  childAspectRatio: 0.55,
                                  crossAxisSpacing: 16,
                                  mainAxisSpacing: 16,
                                ),
                            itemCount: filteredProducts.length,
                            itemBuilder: (context, index) {
                              final product = filteredProducts[index];
                              return _buildProductCard(product);
                            },
                          ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: UserBottomNav(currentItem: BottomNavItem.products),
    );
  }

  Widget _buildProductCard(Product product) {
    String title = product.title;
    title = title.replaceAll('Protien', 'Protein');

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image Area
          Expanded(
            flex: 3,
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(24),
                ),
              ),
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(24),
                ),
                child: SafeImage(imageUrl: product.image),
              ),
            ),
          ),
          // Content Area - Increased Text Sizes
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    product.description.replaceAll('Why', 'Whey'),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF64748B),
                      height: 1.4,
                    ),
                  ),
                  const Spacer(),
                  SizedBox(
                    width: double.infinity,
                    height: 36,
                    child: ElevatedButton(
                      onPressed: () =>
                          context.pushNamed(RouteConstants.contactUsName),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0E6CF2),
                        padding: EdgeInsets.zero,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: const Center(
                        child: Text(
                          'Contact',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
