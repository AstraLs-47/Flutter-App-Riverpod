// Dart imports:
import 'dart:io';

// Flutter imports:
import 'package:flutter/foundation.dart' show debugPrint, kIsWeb;
import 'package:flutter/material.dart';

// Package imports:
import 'package:image_picker/image_picker.dart';

// Project imports:
import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../data/admin_repository.dart';
/* import '../../../../core/models/activity_model.dart'; */
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/image_utils.dart';

class ActivityDetailScreen extends StatelessWidget {
  final Map<String, String> activity; // This holds the current activity data
  final VoidCallback onUpdate;
  final bool showActions;

  const ActivityDetailScreen({
    super.key,
    required this.activity,
    required this.onUpdate,
    this.showActions = true,
  });

  // Mock data generator for workout details based on activity title
  Map<String, dynamic> _getWorkoutDetails() {
    List<Map<String, dynamic>> dynamicSections = [];

    if (activity['warmup'] != null && activity['warmup']!.isNotEmpty) {
      dynamicSections.add({
        'title': '🔥 Warm-Up',
        'content': activity['warmup'],
      });
    }

    if (activity['mainWorkout'] != null &&
        activity['mainWorkout']!.isNotEmpty) {
      final category = activity['category'] ?? 'Exercise';
      String icon = '💪';
      if (category.contains('Cardio')) icon = '🏃';
      if (category.contains('Aerobics')) icon = '🎵';

      dynamicSections.add({
        'title': '$icon Main $category Exercise',
        'content': activity['mainWorkout'],
      });
    }

    // 3. Fallback to Description if no specific sections exist
    if (dynamicSections.isEmpty) {
      dynamicSections.add({
        'title': '📋 Exercise Overview',
        'content':
            (activity['description'] != null &&
                activity['description']!.isNotEmpty)
            ? activity['description']
            : 'No specific workout details provided for this exercise.',
      });
    }

    return {
      'duration':
          (activity['duration'] != null && activity['duration']!.isNotEmpty)
          ? activity['duration']
          : 'N/A',
      'sections': dynamicSections,
      'rest': (activity['rest'] != null && activity['rest']!.isNotEmpty)
          ? activity['rest']
          : 'Standard rest as needed',
    };
  }

  Future<void> _showEditDialog(BuildContext context) async {
    if (AdminRepository().exerciseCategories.isEmpty) {
      await AdminRepository().fetchCategories();
    }

    String newTitle = activity['title'] ?? '';
    String description = activity['description'] ?? '';
    String category = activity['category'] ?? '';
    String selectedImg = activity['image'] ?? 'assets/running_image.jpg';
    XFile? selectedXFile;
    String warmup = activity['warmup'] ?? '';
    String mainWorkout = activity['mainWorkout'] ?? '';
    String rest = activity['rest'] ?? '';
    String duration = activity['duration'] ?? '';

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (dialogContext, setDialogState) {
          // Filter out 'All' and handle empty or mismatched categories
          final availableCategories = AdminRepository().exerciseCategories
              .where((c) => c.toLowerCase() != 'all')
              .toList();

          if (category.isEmpty || !availableCategories.contains(category)) {
            category = availableCategories.isNotEmpty
                ? availableCategories.first
                : '';
          }

          return Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
            backgroundColor: Colors.white,
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    RichText(
                      text: const TextSpan(
                        text: 'Edit ',
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
                    _buildInputField(
                      hintText: 'Exercise name...',
                      initialValue: newTitle,
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
                              (category.isNotEmpty &&
                                  availableCategories.contains(category))
                              ? category
                              : null,
                          isExpanded: true,
                          icon: const Icon(
                            Icons.keyboard_arrow_down,
                            color: Colors.grey,
                          ),
                          hint: const Text(
                            'Select Category',
                            style: TextStyle(color: Colors.grey, fontSize: 13),
                          ),
                          items: AdminRepository().exerciseCategories
                              .where((c) => c.toLowerCase() != 'all')
                              .map((String value) {
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
                              })
                              .toList(),
                          dropdownColor: Colors.white,
                          onChanged: (val) {
                            if (val != null) {
                              setDialogState(() => category = val);
                            }
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildInputField(
                      hintText: 'Description...',
                      initialValue: description,
                      onChanged: (val) => description = val,
                      maxLines: 2,
                      fontSize: 12,
                    ),
                    const SizedBox(height: 16),
                    _buildInputField(
                      hintText: 'Duration (e.g., 45 min)...',
                      initialValue: duration,
                      onChanged: (val) => duration = val,
                      fontSize: 12,
                    ),
                    const SizedBox(height: 16),
                    _buildInputField(
                      hintText: 'Warm-up details...',
                      initialValue: warmup,
                      onChanged: (val) => warmup = val,
                      maxLines: 3,
                      fontSize: 12,
                    ),
                    const SizedBox(height: 16),
                    _buildInputField(
                      hintText: 'Main Exercise (Category) details...',
                      initialValue: mainWorkout,
                      onChanged: (val) => mainWorkout = val,
                      maxLines: 4,
                      fontSize: 12,
                    ),
                    const SizedBox(height: 16),
                    _buildInputField(
                      hintText: 'Rest guidelines...',
                      initialValue: rest,
                      onChanged: (val) => rest = val,
                      maxLines: 2,
                      fontSize: 12,
                    ),
                    const SizedBox(height: 16),
                    InkWell(
                      onTap: () {
                        _pickImage(dialogContext, (xfile) {
                          setDialogState(() {
                            selectedImg = xfile.path;
                            selectedXFile = xfile;
                          });
                        });
                      },
                      child: Container(
                        height: 100,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF5F6F8),
                          borderRadius: BorderRadius.circular(12),
                          image: DecorationImage(
                            image: selectedImg.startsWith('assets/')
                                ? AssetImage(selectedImg) as ImageProvider
                                : ((kIsWeb ||
                                              selectedImg.startsWith('http') ||
                                              selectedImg.startsWith('blob:'))
                                          ? NetworkImage(selectedImg)
                                          : FileImage(File(selectedImg)))
                                      as ImageProvider,
                            fit: BoxFit.cover,
                          ),
                        ),
                        child: Align(
                          alignment: Alignment.bottomRight,
                          child: Container(
                            margin: const EdgeInsets.all(8),
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                              color: Colors.black54,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.camera_alt,
                              color: Colors.white,
                              size: 16,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () async {
                        try {
                          final imageUrl = await _uploadImageIfNeeded(
                            selectedXFile ?? selectedImg,
                          );

                          final Map<String, String> updatedActivity = {
                            'id': activity['id']!,
                            'title': newTitle,
                            'description': description,
                            'category': category,
                            'image': imageUrl,
                            'warmup': warmup,
                            'mainWorkout': mainWorkout,
                            'rest': rest,
                            'duration': duration,
                          };

                          // Use AdminRepository as the source of truth for updates
                          // to ensure dashboard, local list, and database are in sync
                          await AdminRepository().updateActivity(
                            activity,
                            updatedActivity,
                          );

                          onUpdate(); // Callback Pattern

                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Exercise updated successfully!'),
                                backgroundColor: Colors.green,
                              ),
                            );
                          }
                          if (ctx.mounted) Navigator.pop(ctx);
                          if (context.mounted) Navigator.pop(context);
                        } catch (e) {
                          debugPrint('Activity Update failed: $e');
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Failed to update: $e'),
                                backgroundColor: Colors.red,
                              ),
                            );
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
                      child: const Text(
                        'Save Changes',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(ctx),
                      child: const Text(
                        'Cancel',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildInputField({
    required String hintText,
    required String initialValue,
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
        fillColor: const Color(0xFFF5F6F8),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
      ),
    );
  }

  void _showDeleteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        backgroundColor: Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Remove Exercise',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Are you sure you want to remove this exercise from the activity list?',
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
                      onPressed: () async {
                        // Use AdminRepository for deletion to keep state in sync
                        await AdminRepository().removeActivity(activity);
                        if (ctx.mounted) Navigator.pop(ctx); // Close Dialog
                        onUpdate(); // Refresh Parent
                        if (context.mounted) {
                          Navigator.pop(context); // Close Detail Screen
                        }
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
                      onPressed: () => Navigator.pop(ctx),
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
      ),
    );
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
      }
    } catch (e) {
      debugPrint('Activity image upload failed: $e');
    }
    return '';
  }

  void _pickImage(BuildContext context, Function(XFile) onPicked) async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      onPicked(image);
    }
  }

  @override
  Widget build(BuildContext context) {
    final String title = activity['title'] ?? 'Activity';
    final details = _getWorkoutDetails();
    final sections = details['sections'] as List<Map<String, dynamic>>;

    // Check if alignment should be topCenter for specific images
    final Alignment imageAlignment =
        (title.toLowerCase().contains('running') ||
            title.toLowerCase().contains('cardio'))
        ? const Alignment(0, -0.1)
        : Alignment.center;

    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 340,
            pinned: true,
            backgroundColor: Colors.white,
            surfaceTintColor: Colors.transparent,
            scrolledUnderElevation: 0,
            elevation: 0,
            automaticallyImplyLeading: false,
            leadingWidth: 70,
            leading: Center(
              child: Padding(
                padding: const EdgeInsets.only(left: 16.0),
                child: GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.arrow_back,
                      color: Colors.black,
                      size: 20,
                    ),
                  ),
                ),
              ),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Hero(
                tag: activity['title'] ?? 'activity',
                child: SafeImage(
                  imageUrl: activity['image'] ?? '',
                  fit: BoxFit.cover,
                  alignment: imageAlignment,
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 24.0,
                vertical: 16.0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Meta Info Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Text(
                              activity['category']?.toUpperCase() ?? 'CARDIO',
                              style: const TextStyle(
                                color: AppColors.primary,
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          if (details['duration'] != null) ...[
                            const Icon(
                              Icons.access_time,
                              size: 14,
                              color: Colors.grey,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              details['duration'] as String,
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ],
                      ),
                      if (showActions)
                        Row(
                          children: [
                            InkWell(
                              onTap: () => _showEditDialog(context),
                              child: const Icon(
                                Icons.edit,
                                size: 20,
                                color: AppColors.primary,
                              ),
                            ),
                            const SizedBox(width: 16),
                            InkWell(
                              onTap: () => _showDeleteDialog(context),
                              child: const Icon(
                                Icons.delete_outline,
                                size: 20,
                                color: Colors.red,
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Title and Description
                  Text(
                    activity['title'] ?? 'Activity',
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    activity['description'] ?? '',
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Workout Sections
                  ...sections.map((section) => _buildSection(section)),

                  // Rest Guidelines
                  if (details['rest'] != null) ...[
                    const SizedBox(height: 16),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.04),
                            blurRadius: 16,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(
                            Icons.pause_circle_outline,
                            size: 16,
                            color: AppColors.primary,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              details['rest'] as String,
                              style: const TextStyle(
                                color: AppColors.textPrimary,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                height: 1.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: 48), // Bottom padding
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(Map<String, dynamic> section) {
    final String title = section['title'];

    // Check if it's custom content (String) or preset items (List)
    final dynamic content = section['content'];
    final List<Map<String, String>>? items = section['items'] != null
        ? (section['items'] as List).cast<Map<String, String>>()
        : null;

    return Padding(
      padding: const EdgeInsets.only(bottom: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            padding: const EdgeInsets.all(20),
            child: items != null
                ? Column(
                    children: items.asMap().entries.map((entry) {
                      int idx = entry.key;
                      Map<String, String> item = entry.value;
                      bool isLast = idx == items.length - 1;
                      return Padding(
                        padding: EdgeInsets.only(bottom: isLast ? 0 : 16.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 24,
                              height: 24,
                              decoration: BoxDecoration(
                                color: AppColors.primary.withValues(
                                  alpha: 0.15,
                                ),
                                shape: BoxShape.circle,
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                '${idx + 1}',
                                style: const TextStyle(
                                  color: AppColors.primary,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item['title']!,
                                    style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.access_time,
                                        size: 10,
                                        color: Colors.grey,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        item['duration']!,
                                        style: const TextStyle(
                                          fontSize: 11,
                                          color: Colors.grey,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                  if (item['note']!.isNotEmpty) ...[
                                    const SizedBox(height: 4),
                                    Text(
                                      item['note']!,
                                      style: const TextStyle(
                                        fontSize: 11,
                                        color: AppColors.textSecondary,
                                        fontStyle: FontStyle.italic,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  )
                : Text(
                    content as String,
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                      height: 1.6,
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
