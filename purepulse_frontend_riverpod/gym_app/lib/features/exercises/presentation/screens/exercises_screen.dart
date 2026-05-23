// Dart imports:
import 'dart:io';

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:go_router/go_router.dart';

// Project imports:
import '../../../../core/constants/route_constants.dart';
import '../../../../core/models/activity_model.dart';
import '../../../admin/data/admin_repository.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/navigation_helper.dart';
import '../../../../core/widgets/user_bottom_nav.dart';
import '../../data/exercise_service.dart';

class ExercisesScreen extends StatefulWidget {
  const ExercisesScreen({super.key});

  @override
  State<ExercisesScreen> createState() => _ExercisesScreenState();
}

class _ExercisesScreenState extends State<ExercisesScreen> {
  final ExerciseService _exerciseService = ExerciseService();
  String _selectedCategory = 'All';
  late Future<List<Activity>> _activitiesFuture;
  List<String> _activityCategories = ['All'];

  List<Map<String, dynamic>> get _categories =>
      _activityCategories.map((n) => {'name': n, 'icon': null}).toList();

  @override
  void initState() {
    super.initState();
    try {
      _refreshActivities();
      // load categories from backend as a fallback and keep state in sync
      AdminRepository()
          .fetchCategories()
          .then((_) {
            if (mounted) {
              setState(() {
                _activityCategories = [
                  'All',
                  ...AdminRepository().activityCategories.where(
                    (name) => name != 'All',
                  ),
                ];
              });
            }
          })
          .catchError((e) {
            debugPrint('Category fetch failed: $e');
          });
    } catch (e) {
      debugPrint('Initialization error in ExercisesScreen: $e');
      _activitiesFuture = Future.value([]);
    }
  }

  void _refreshActivities() {
    setState(() {
      _activitiesFuture = _exerciseService.fetchActivities().then((activities) {
        if (mounted) {
          setState(() {
            _activityCategories = _buildCategoryList(activities);
          });
        }
        return activities;
      });
    });
  }

  List<String> _buildCategoryList(List<Activity> activities) {
    final categorySet = <String>{'All'};
    categorySet.addAll(
      AdminRepository().exerciseCategories.where((name) => name != 'All'),
    );

    for (final activity in activities) {
      final category = _capitalize(activity.category.trim());
      if (category.isNotEmpty) {
        categorySet.add(category);
      }
    }

    return categorySet.toList();
  }

  List<Activity> _filterActivities(
    List<Activity> activities,
    String selectedCategory,
  ) {
    if (selectedCategory == 'All') return activities;
    return activities.where((a) {
      return a.category.trim().toUpperCase() ==
          selectedCategory.trim().toUpperCase();
    }).toList();
  }

  String _capitalize(String s) {
    if (s.isEmpty) return s;
    return s[0].toUpperCase() + s.substring(1).toLowerCase();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'WORKOUT',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF94A3B8),
                          letterSpacing: 0.5,
                        ),
                      ),
                      const Text(
                        'Exercises',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1E293B),
                        ),
                      ),
                    ],
                  ),
                  Stack(
                    children: [
                      IconButton(
                        icon: const Icon(
                          Icons.notifications_none_outlined,
                          size: 32,
                          color: Colors.black54,
                        ),
                        onPressed: () {
                          setState(() {
                            AdminRepository().markAnnouncementsAsViewed();
                          });
                          context.pushNamed(RouteConstants.announcementsName);
                        },
                      ),
                      if (AdminRepository().hasNewAnnouncements)
                        Positioned(
                          right: 12,
                          top: 12,
                          child: Container(
                            width: 10,
                            height: 10,
                            decoration: const BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),

            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.0),
              child: Text(
                'Follow expert-designed workout sets',
                style: TextStyle(fontSize: 14, color: Color(0xFF64748B)),
              ),
            ),
            const SizedBox(height: 24),

            // Categories
            SizedBox(
              height: 44,
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
                    final isSelected = _selectedCategory == cat['name'];
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 6),
                      child: GestureDetector(
                        onTap: () =>
                            setState(() => _selectedCategory = cat['name']),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? const Color(0xFF0E6CF2)
                                : Colors.white,
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.04),
                                blurRadius: 10,
                              ),
                            ],
                          ),
                          child: Text(
                            cat['name'],
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
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Workout List with FutureBuilder
            Expanded(
              child: FutureBuilder<List<Activity>>(
                future: _activitiesFuture,
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
                        'No exercises found',
                        style: TextStyle(color: AppColors.textSecondary),
                      ),
                    );
                  }

                  final rawActivities = snapshot.data!;
                  final selectedCategory =
                      _activityCategories.contains(_selectedCategory)
                      ? _selectedCategory
                      : 'All';
                  final filteredActivities = _filterActivities(
                    rawActivities,
                    selectedCategory,
                  );

                  return ScrollConfiguration(
                    behavior: ScrollConfiguration.of(
                      context,
                    ).copyWith(scrollbars: false),
                    child: filteredActivities.isEmpty
                        ? const Center(
                            child: Text(
                              'No exercises found in this category',
                              style: TextStyle(color: AppColors.textSecondary),
                            ),
                          )
                        : GridView.builder(
                            physics: const BouncingScrollPhysics(),
                            padding: const EdgeInsets.fromLTRB(24, 0, 24, 80),
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2,
                                  crossAxisSpacing: 16,
                                  mainAxisSpacing: 16,
                                  childAspectRatio: 0.60,
                                ),
                            itemCount: filteredActivities.length,
                            itemBuilder: (context, index) {
                              return _buildAdminStyleUserCard(
                                filteredActivities[index],
                              );
                            },
                          ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: UserBottomNav(currentItem: BottomNavItem.exercises),
    );
  }

  Widget _buildAdminStyleUserCard(Activity workout) {
    return GestureDetector(
      onTap: () => context.pushNamed(
        RouteConstants.exerciseDetailName,
        extra: workout.toJson().map((k, v) => MapEntry(k, v.toString())),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 15,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 3,
                child: Container(
                  width: double.infinity,
                  color: const Color(0xFFF1F5F9),
                  child: Builder(
                    builder: (context) {
                      final String path = workout.image.trim();
                      final bool isNetwork = path.startsWith('http');
                      final bool isLocalFile =
                          path.startsWith('/') ||
                          path.startsWith('file://') ||
                          path.contains(':\\');

                      final alignment =
                          (workout.title.toLowerCase().contains('cardio') ||
                              workout.title.toLowerCase().contains('running'))
                          ? const Alignment(0, -0.2)
                          : Alignment.topCenter;

                      ImageProvider imageProvider;

                      if (path.isEmpty ||
                          path == 'assets/runner_background_image.jpg') {
                        imageProvider = const AssetImage(
                          'assets/runner_background_image.jpg',
                        );
                      } else if (isNetwork) {
                        imageProvider = NetworkImage(path);
                      } else if (isLocalFile) {
                        imageProvider = FileImage(
                          File(path.replaceFirst('file://', '')),
                        );
                      } else {
                        // Only fallback to runner image if asset path is invalid or not the allowed one
                        imageProvider = const AssetImage(
                          'assets/runner_background_image.jpg',
                        );
                      }

                      return AnimatedSwitcher(
                        duration: const Duration(milliseconds: 300),
                        child: Image(
                          key: ValueKey(path),
                          image: imageProvider,
                          fit: BoxFit.cover,
                          alignment: alignment,
                          errorBuilder: (context, error, stackTrace) =>
                              Image.asset(
                                'assets/runner_background_image.jpg',
                                fit: BoxFit.cover,
                              ),
                        ),
                      );
                    },
                  ),
                ),
              ),
              Expanded(
                flex: 2,
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        workout.title,
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
                        workout.description,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF94A3B8),
                          height: 1.4,
                        ),
                      ),
                      const Spacer(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: const [
                          Text(
                            'View Details',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF0E6CF2),
                            ),
                          ),
                          SizedBox(width: 4),
                          Icon(
                            Icons.chevron_right,
                            size: 14,
                            color: Color(0xFF0E6CF2),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
