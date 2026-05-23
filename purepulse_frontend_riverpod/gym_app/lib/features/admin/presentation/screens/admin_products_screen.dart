// Dart imports:
import 'dart:io';

// Flutter imports:
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';

// Package imports:
import 'package:image_picker/image_picker.dart';

// Project imports:
import '../../../../core/models/product_model.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../data/admin_repository.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../products/data/product_service.dart';
import '../widgets/admin_bottom_nav.dart';
import '../widgets/admin_product_card.dart';

class AdminProductsScreen extends StatefulWidget {
  const AdminProductsScreen({super.key});

  @override
  State<AdminProductsScreen> createState() => _AdminProductsScreenState();
}

class _AdminProductsScreenState extends State<AdminProductsScreen> {
  final ProductService _productService = ProductService();
  late Future<List<Product>> _productsFuture;

  @override
  void initState() {
    super.initState();
    AdminRepository().fetchCategories();
    _refreshProducts();
  }

  void _refreshProducts() {
    setState(() {
      _productsFuture = _productService.fetchProducts();
    });
  }

  void _removeProduct(String id) async {
    // Capture product data before deletion to update AdminRepository
    final products = await _productsFuture;
    final productToRemove = products.firstWhere((p) => p.id == id);

    // 1. Optimistic UI update: remove item from the view immediately
    setState(() {
      _productsFuture = Future.value(
        products.where((p) => p.id != id).toList(),
      );
    });

    // 2. Perform actual background deletion
    // Use AdminRepository as the single point of truth for admin deletions.
    // It handles the API call, local database persistence, and dashboard stats.
    AdminRepository()
        .removeProduct(
          productToRemove.toJson().map((k, v) => MapEntry(k, v.toString())),
        )
        .then((_) => _refreshProducts());
  }

  void _pickImage(BuildContext context, Function(XFile) onPicked) async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      onPicked(image);
    }
  }

  Future<String> _uploadImageIfNeeded(dynamic fileOrPath) async {
    if (fileOrPath == null) return '';

    try {
      // If it's already a network/asset/blob path string, return as-is
      if (fileOrPath is String) {
        final path = fileOrPath;
        if (path.isEmpty ||
            path.startsWith('http') ||
            path.startsWith('assets/') ||
            path.startsWith('blob:')) {
          return path;
        }
        final response = await ApiClient().uploadFile(
          ApiEndpoints.uploads,
          path,
        );
        if (response is Map<String, dynamic>) {
          return response['imageUrl']?.toString() ?? path;
        }
        return path;
      }

      if (fileOrPath is XFile) {
        final response = await ApiClient().uploadFile(
          ApiEndpoints.uploads,
          fileOrPath,
        );
        if (response is Map<String, dynamic>) {
          return response['imageUrl']?.toString() ?? '';
        }
        return '';
      }

      if (fileOrPath is File) {
        final response = await ApiClient().uploadFile(
          ApiEndpoints.uploads,
          fileOrPath,
        );
        if (response is Map<String, dynamic>) {
          return response['imageUrl']?.toString() ?? '';
        }
        return '';
      }
    } catch (e) {
      debugPrint('Product image upload failed: $e');
    }

    return '';
  }

  void _showAddDialog() {
    _showProductDialog(isEdit: false);
  }

  void _showEditDialog(Map<String, String> product) {
    _showProductDialog(isEdit: true, initialData: product);
  }

  void _showDeleteDialog(Map<String, String> product) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          elevation: 0,
          backgroundColor: Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Remove Product',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Are you sure you want to remove this product from the inventory?',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          _removeProduct(product['id']!);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          elevation: 0,
                        ),
                        child: const Text(
                          'Delete',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 2,
                      child: TextButton(
                        onPressed: () => Navigator.pop(context),
                        style: TextButton.styleFrom(
                          backgroundColor: const Color(0xFFF0F0F0),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: const Text(
                          'Cancel',
                          style: TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildInputField({
    required String hintText,
    String? initialValue,
    required ValueChanged<String> onChanged,
    int maxLines = 1,
    double fontSize = 13,
  }) {
    return TextFormField(
      initialValue: initialValue,
      onChanged: onChanged,
      maxLines: maxLines,
      style: TextStyle(fontSize: fontSize, color: AppColors.textPrimary),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(color: Colors.grey, fontSize: fontSize),
        filled: true,
        fillColor: const Color(0xFFF8F9FA),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
      ),
    );
  }

  Future<void> _showProductDialog({
    required bool isEdit,
    Map<String, String>? initialData,
  }) async {
    if (AdminRepository().productCategories.isEmpty) {
      await AdminRepository().fetchCategories();
    }

    String title = initialData?['title'] ?? '';
    String description = initialData?['description'] ?? '';
    String selectedImg = initialData?['image'] ?? '';
    XFile? selectedXFile;
    String selectedCat = initialData?['category'] ?? '';

    // Normalize the category string once, and keep the field state across dialog rebuilds.
    if (selectedCat.isNotEmpty) {
      selectedCat =
          selectedCat[0].toUpperCase() + selectedCat.substring(1).toLowerCase();
    }

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            final availableCategories = AdminRepository().productCategories;

            if (!availableCategories.contains(selectedCat)) {
              selectedCat = availableCategories.isNotEmpty
                  ? availableCategories.first
                  : '';
            }

            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              elevation: 0,
              backgroundColor: Colors.white,
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    RichText(
                      text: TextSpan(
                        text: isEdit ? 'Edit ' : 'Add ',
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                        children: const [
                          TextSpan(
                            text: 'Product',
                            style: TextStyle(color: AppColors.primary),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    Flexible(
                      child: SingleChildScrollView(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            InkWell(
                              onTap: () {
                                _pickImage(context, (xfile) {
                                  setDialogState(() {
                                    selectedImg = xfile.path;
                                    selectedXFile = xfile;
                                  });
                                });
                              },
                              child: Container(
                                height: 140,
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF8F9FA),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: Colors.grey.withValues(alpha: 0.3),
                                  ),
                                  image: selectedImg.isNotEmpty
                                      ? DecorationImage(
                                          image:
                                              selectedImg.startsWith('assets/')
                                              ? AssetImage(selectedImg)
                                                    as ImageProvider
                                              : ((kIsWeb ||
                                                            selectedImg
                                                                .startsWith(
                                                                  'http',
                                                                ) ||
                                                            selectedImg
                                                                .startsWith(
                                                                  'blob:',
                                                                ))
                                                        ? NetworkImage(
                                                            selectedImg,
                                                          )
                                                        : FileImage(
                                                            File(selectedImg),
                                                          ))
                                                    as ImageProvider,
                                          fit: BoxFit.cover,
                                        )
                                      : null,
                                ),
                                child: selectedImg.isEmpty
                                    ? Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: const [
                                          Icon(
                                            Icons.add_photo_alternate_outlined,
                                            size: 40,
                                            color: Colors.grey,
                                          ),
                                          SizedBox(height: 8),
                                          Text(
                                            'Upload Image',
                                            style: TextStyle(
                                              color: Colors.grey,
                                              fontSize: 13,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ],
                                      )
                                    : Align(
                                        alignment: Alignment.bottomRight,
                                        child: Container(
                                          margin: const EdgeInsets.all(8),
                                          padding: const EdgeInsets.all(4),
                                          decoration: const BoxDecoration(
                                            color: Colors.black54,
                                            shape: BoxShape.circle,
                                          ),
                                          child: const Icon(
                                            Icons.edit,
                                            color: Colors.white,
                                            size: 16,
                                          ),
                                        ),
                                      ),
                              ),
                            ),
                            const SizedBox(height: 20),
                            _buildInputField(
                              initialValue: title,
                              hintText: 'Product name...',
                              onChanged: (val) => title = val,
                              fontSize: 18,
                            ),
                            const SizedBox(height: 16),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF8F9FA),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton<String>(
                                  value: selectedCat.isNotEmpty
                                      ? selectedCat
                                      : null,
                                  isExpanded: true,
                                  icon: const Icon(
                                    Icons.keyboard_arrow_down,
                                    color: Colors.grey,
                                  ),
                                  hint: const Text(
                                    'Select Category',
                                    style: TextStyle(
                                      color: Colors.grey,
                                      fontSize: 13,
                                    ),
                                  ),
                                  items: availableCategories.map((
                                    String catName,
                                  ) {
                                    return DropdownMenuItem<String>(
                                      value: catName,
                                      child: Text(
                                        catName,
                                        style: const TextStyle(
                                          fontSize: 13,
                                          color: AppColors.textPrimary,
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                  dropdownColor: Colors.white,
                                  onChanged: (val) {
                                    if (val != null) {
                                      setDialogState(() => selectedCat = val);
                                    }
                                  },
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            _buildInputField(
                              initialValue: description,
                              hintText: 'Description...',
                              onChanged: (val) => description = val,
                              maxLines: 3,
                              fontSize: 13,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Expanded(
                          flex: 3,
                          child: ElevatedButton(
                            onPressed: () async {
                              final currentContext = context;
                              if (title.isNotEmpty) {
                                final imageUrl = await _uploadImageIfNeeded(
                                  selectedXFile ?? selectedImg,
                                );
                                if (isEdit && initialData != null) {
                                  final product = Product(
                                    id: initialData['id']!,
                                    title: title,
                                    description: description,
                                    category: selectedCat,
                                    image: imageUrl,
                                  );
                                  await _productService.updateProduct(product);
                                } else {
                                  final product = Product(
                                    id: DateTime.now().millisecondsSinceEpoch
                                        .toString(),
                                    title: title,
                                    description: description,
                                    category: selectedCat,
                                    image: imageUrl.isNotEmpty
                                        ? imageUrl
                                        : 'assets/pro_dumbbells.png',
                                  );
                                  // Use AdminRepository to keep all states (dashboard, local list, DB) in sync
                                  await AdminRepository().addProduct(
                                    product.toJson().map(
                                      (k, v) => MapEntry(k, v.toString()),
                                    ),
                                  );
                                }
                                _refreshProducts();
                                if (mounted) {
                                  Navigator.pop(currentContext);
                                }
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              elevation: 0,
                            ),
                            child: Text(
                              isEdit ? 'Edit Product' : 'Add Product',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          flex: 2,
                          child: TextButton(
                            onPressed: () => Navigator.pop(context),
                            style: TextButton.styleFrom(
                              backgroundColor: const Color(0xFFF0F0F0),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 16),
                            ),
                            child: const Text(
                              'Cancel',
                              style: TextStyle(
                                color: AppColors.textPrimary,
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showAddCategoryDialog() {
    String newCategory = '';
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            final currentCategories = AdminRepository().productCategories;
            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              elevation: 0,
              backgroundColor: Colors.white,
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      'Manage Product Categories',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Add Category Input
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            onChanged: (val) => newCategory = val,
                            decoration: InputDecoration(
                              hintText: 'New product category...',
                              hintStyle: const TextStyle(fontSize: 13),
                              filled: true,
                              fillColor: const Color(0xFFF8F9FA),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: IconButton(
                            icon: const Icon(Icons.add, color: Colors.white),
                            onPressed: () {
                              if (newCategory.isNotEmpty) {
                                AdminRepository().addProductCategory(
                                  newCategory,
                                );
                                setDialogState(() {}); // Refresh dialog list
                                setState(() {}); // Refresh screen state
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'EXISTING CATEGORIES',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey,
                        letterSpacing: 1.0,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Flexible(
                      child: Container(
                        constraints: const BoxConstraints(maxHeight: 200),
                        child: ListView.builder(
                          shrinkWrap: true,
                          itemCount: currentCategories.length,
                          itemBuilder: (context, index) {
                            final cat = currentCategories[index];
                            return Container(
                              margin: const EdgeInsets.only(bottom: 8),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF8F9FA),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.shopping_bag_outlined,
                                    size: 14,
                                    color: AppColors.primary,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      cat,
                                      style: const TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(
                                      Icons.delete_outline,
                                      size: 18,
                                      color: Colors.red,
                                    ),
                                    onPressed: () {
                                      AdminRepository().removeProductCategory(
                                        cat,
                                      );
                                      setDialogState(() {});
                                      setState(() {});
                                    },
                                    padding: EdgeInsets.zero,
                                    constraints: const BoxConstraints(),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      style: TextButton.styleFrom(
                        backgroundColor: const Color(0xFFF0F0F0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: const Text(
                        'Close',
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        toolbarHeight: 90, // Match Activities screen
        backgroundColor: Colors.white,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        title: Padding(
          padding: const EdgeInsets.only(top: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text(
                'MANAGE',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
              Text(
                'Products',
                style: TextStyle(
                  color: AppColors.primary,
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(top: 16.0),
            child: Container(
              margin: const EdgeInsets.only(right: 8, top: 8, bottom: 8),
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.borderColor),
              ),
              child: IconButton(
                padding: EdgeInsets.zero,
                icon: const Icon(
                  Icons.local_offer,
                  color: AppColors.primary,
                  size: 20,
                ),
                onPressed: _showAddCategoryDialog,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 16.0),
            child: Container(
              margin: const EdgeInsets.only(right: 20, top: 8, bottom: 8),
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(12),
              ),
              child: IconButton(
                padding: EdgeInsets.zero,
                icon: const Icon(Icons.add, color: Colors.white, size: 24),
                onPressed: _showAddDialog,
              ),
            ),
          ),
        ],
      ),
      body: FutureBuilder<List<Product>>(
        future: _productsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
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

          final products = snapshot.data!;

          return ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: products.length,
            itemBuilder: (context, index) {
              final product = products[index];
              return AdminProductCard(
                title: product.title,
                description: product.description,
                category: product.category,
                imageUrl: product.image,
                onEdit: () => _showEditDialog(
                  product.toJson().map((k, v) => MapEntry(k, v.toString())),
                ),
                onDelete: () => _showDeleteDialog(
                  product.toJson().map((k, v) => MapEntry(k, v.toString())),
                ),
              );
            },
          );
        },
      ),
      bottomNavigationBar: const AdminBottomNav(currentIndex: 2),
    );
  }
}
