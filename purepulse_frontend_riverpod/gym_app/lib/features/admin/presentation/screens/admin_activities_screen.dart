// Dart imports:
import 'dart:io';

// Flutter imports:
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';

// Package imports:
import 'package:image_picker/image_picker.dart';

// Project imports:
import '../../../../core/models/activity_model.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../data/admin_repository.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/activity_card.dart';
import '../../../exercises/data/exercise_service.dart';
import '../widgets/admin_bottom_nav.dart';
import 'activity_detail_screen.dart';

class AdminActivitiesScreen extends StatefulWidget {
  const AdminActivitiesScreen({super.key});

  @override
  State<AdminActivitiesScreen> createState() => _AdminActivitiesScreenState();
}

class _AdminActivitiesScreenState extends State<AdminActivitiesScreen> {
  final ExerciseService _exerciseService = ExerciseService();
  late Future<List<Activity>> _activitiesFuture;
  String _selectedFilter = 'All';
  final TextEditingController _categoryController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Align logic with products: fetch categories on initialization
    AdminRepository().fetchCategories().then((_) {
      if (mounted) setState(() {});
    });
    _refreshActivities();
  }

  void _refreshActivities() {
    setState(() {
      _activitiesFuture = _exerciseService.fetchActivities();
    });
  }

  @override
  void dispose() {
    _categoryController.dispose();
    super.dispose();
  }

  Future<void> _addActivity(Activity activity) async {
    // Use AdminRepository to keep all states (dashboard, local list, DB) in sync
    await AdminRepository().addActivity(
      activity.toJson().map((k, v) => MapEntry(k, v.toString())),
    );
    _refreshActivities();
  }

  Widget _buildInputField({
    required String hintText,
    required ValueChanged<String> onChanged,
    int maxLines = 1,
    double fontSize = 13,
  }) {
    return TextField(
      onChanged: onChanged,
      maxLines: maxLines,
      style: TextStyle(fontSize: fontSize, color: AppColors.textPrimary),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(color: Colors.grey, fontSize: fontSize),
        filled: true,
        fillColor: const Color(0xFFF5F6F8),
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

  Future<void> _showAddDialog() async {
    String newTitle = '';
    String description = '';
    String selectedImage = '';
    XFile? selectedXFile;
    String warmup = '';
    String mainWorkout = '';
    String rest = '';
    String duration = '';
    String selectedCat = '';

    if (AdminRepository().exerciseCategories.isEmpty) {
      await AdminRepository().fetchCategories();
    }

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            // Filter out 'All' for the creation dropdown
            final availableCategories = AdminRepository().exerciseCategories
                .where((c) => c.toLowerCase() != 'all')
                .toList();

            // Safe initialization of selectedCat
            if (selectedCat.isEmpty ||
                !availableCategories.contains(selectedCat)) {
              selectedCat = availableCategories.isNotEmpty
                  ? availableCategories.first
                  : '';
            }

            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              elevation: 8,
              backgroundColor: Colors.white,
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    RichText(
                      text: const TextSpan(
                        text: 'New ',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                        children: [
                          TextSpan(
                            text: 'Exercise',
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
                                    selectedImage = xfile.path;
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
                                  image: selectedImage.isNotEmpty
                                      ? DecorationImage(
                                          image:
                                              selectedImage.startsWith(
                                                'assets/',
                                              )
                                              ? AssetImage(selectedImage)
                                                    as ImageProvider
                                              : ((kIsWeb ||
                                                            selectedImage
                                                                .startsWith(
                                                                  'http',
                                                                ) ||
                                                            selectedImage
                                                                .startsWith(
                                                                  'blob:',
                                                                ))
                                                        ? NetworkImage(
                                                            selectedImage,
                                                          )
                                                        : FileImage(
                                                            File(selectedImage),
                                                          ))
                                                    as ImageProvider,
                                          fit: BoxFit.cover,
                                        )
                                      : null,
                                ),
                                child: selectedImage.isEmpty
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
                              hintText: 'Exercise name...',
                              onChanged: (val) => newTitle = val,
                              fontSize: 16,
                            ),
                            const SizedBox(height: 16),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF5F6F8),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton<String>(
                                  value:
                                      (selectedCat.isNotEmpty &&
                                          availableCategories.contains(
                                            selectedCat,
                                          ))
                                      ? selectedCat
                                      : null,
                                  isExpanded: true,
                                  icon: const Icon(
                                    Icons.keyboard_arrow_down,
                                    color: Colors.grey,
                                  ),
                                  items: availableCategories.map((
                                    String value,
                                  ) {
                                    return DropdownMenuItem<String>(
                                      value: value,
                                      child: Text(
                                        value,
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
                              hintText: 'Description...',
                              onChanged: (val) => description = val,
                              maxLines: 2,
                              fontSize: 12,
                            ),
                            const SizedBox(height: 16),
                            _buildInputField(
                              hintText: 'Duration (e.g., 45 min)...',
                              onChanged: (val) => duration = val,
                              fontSize: 12,
                            ),
                            const SizedBox(height: 16),
                            _buildInputField(
                              hintText: 'Warm-up details...',
                              onChanged: (val) => warmup = val,
                              maxLines: 3,
                              fontSize: 12,
                            ),
                            const SizedBox(height: 16),
                            _buildInputField(
                              hintText: 'Main Exercise details...',
                              onChanged: (val) => mainWorkout = val,
                              maxLines: 4,
                              fontSize: 12,
                            ),
                            const SizedBox(height: 16),
                            _buildInputField(
                              hintText: 'Rest guidelines...',
                              onChanged: (val) => rest = val,
                              maxLines: 2,
                              fontSize: 12,
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
                              if (newTitle.isNotEmpty) {
                                final imageUrl = await _uploadImageIfNeeded(
                                  selectedXFile ?? selectedImage,
                                );
                                final activity = Activity(
                                  id: DateTime.now().millisecondsSinceEpoch
                                      .toString(),
                                  title: newTitle,
                                  description: description,
                                  image: imageUrl,
                                  categoryId: AdminRepository()
                                      .getExerciseCategoryId(selectedCat),
                                  category: selectedCat,
                                  warmup: warmup,
                                  mainWorkout: mainWorkout,
                                  rest: rest,
                                  duration: duration,
                                );

                                await _addActivity(activity);
                              }
                              if (mounted) Navigator.pop(context);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              elevation: 0,
                            ),
                            child: const Text(
                              'Create Exercise',
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
                          child: OutlinedButton(
                            onPressed: () => Navigator.pop(context),
                            style: OutlinedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              side: const BorderSide(
                                color: Colors.grey,
                                width: 1,
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 16),
                            ),
                            child: const Text(
                              'Cancel',
                              style: TextStyle(
                                color: Colors.black87,
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
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
      debugPrint('Activity image upload failed: $e');
    }

    return '';
  }

  void _showAddCategoryDialog() {
    String newCategory = '';
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            final currentCategories = AdminRepository().exerciseCategories;
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
                      'Manage Activity Categories',
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
                              hintText: 'New category...',
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
                                AdminRepository().addCategory(newCategory);
                                setDialogState(() {}); // Refresh dialog list
                                setState(() {}); // Refresh background list
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
                                    Icons.label_outline,
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
                                    onPressed: () async {
                                      await AdminRepository().removeCategory(
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
        toolbarHeight: 90,
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
                'Activities',
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
      body: FutureBuilder<List<Activity>>(
        future: _activitiesFuture,
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
                'No exercises found',
                style: TextStyle(color: AppColors.textSecondary),
              ),
            );
          }

          final activities = snapshot.data!;
          final displayedActivities = _selectedFilter == 'All'
              ? activities
              : activities
                    .where(
                      (a) =>
                          a.category.trim().toLowerCase() ==
                          _selectedFilter.trim().toLowerCase(),
                    )
                    .toList();

          final categories = AdminRepository().activityCategories;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: 48,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: categories.length,
                  itemBuilder: (context, index) {
                    final filter = categories[index];
                    final isSelected = _selectedFilter == filter;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: GestureDetector(
                        onTap: () {
                          setState(() => _selectedFilter = filter);
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppColors.primary
                                : const Color(0xFFF5F6F8),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            filter,
                            style: TextStyle(
                              color: isSelected
                                  ? Colors.white
                                  : AppColors.textSecondary,
                              fontSize: 13,
                              fontWeight: isSelected
                                  ? FontWeight.w600
                                  : FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: SizedBox(
                  width: double.infinity,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.only(
                      left: 16,
                      right: 16,
                      top: 20,
                      bottom: 48,
                    ),
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final itemWidth = (constraints.maxWidth - 16) / 2;
                        return Wrap(
                          spacing: 16,
                          runSpacing: 16,
                          alignment: WrapAlignment.start,
                          children: displayedActivities.map((activity) {
                            return SizedBox(
                              width: itemWidth,
                              height: 320,
                              child: ActivityCard(
                                title: activity.title,
                                description: activity.description,
                                imageUrl: activity.image.isNotEmpty
                                    ? activity.image
                                    : 'assets/running_image.jpg',
                                alignment:
                                    (activity.title == 'Jump Rope' ||
                                        activity.title == 'Dynamic Aerobics' ||
                                        activity.title == 'Cycling')
                                    ? Alignment.topCenter
                                    : (activity.title.toLowerCase().contains(
                                            'running',
                                          ) ||
                                          activity.title.toLowerCase().contains(
                                            'cardio',
                                          ))
                                    ? const Alignment(0, -0.2)
                                    : Alignment.center,
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          ActivityDetailScreen(
                                            activity: activity.toJson().map(
                                              (k, v) =>
                                                  MapEntry(k, v.toString()),
                                            ),
                                            onUpdate: _refreshActivities,
                                          ),
                                    ),
                                  );
                                },
                              ),
                            );
                          }).toList(),
                        );
                      },
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
      bottomNavigationBar: const AdminBottomNav(currentIndex: 1),
    );
  }
}
