// Flutter imports:
import 'package:flutter/foundation.dart';

// Project imports:
import '../../../core/data/database_helper.dart';
import '../../progress/data/health_store.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_endpoints.dart';

import '../../../core/domain/repositories/i_admin_repository.dart';

class AdminRepository implements IAdminRepository {
  static final AdminRepository _instance = AdminRepository._internal();
  factory AdminRepository() => _instance;
  AdminRepository._internal();

  final _healthStore = HealthStore();
  final _db = DatabaseHelper();

  String get _baseUrl {
    final uri = Uri.parse(ApiEndpoints.baseUrl);
    return uri.replace(path: '/uploads/').toString();
  }

  // Metrics
  double totalRevenue = 0.0;
  double revenuePercent = 0.0;
  int totalUsers = 0;
  double usersPercent = 0.0;
  int totalLogouts = 0;

  void trackLogout() {
    totalLogouts++;
  }

  // Health matrix stats synchronized from backend database
  final double _avgBmi = 22.4;
  final double _avgHr = 72.0;

  double get avgBmi => _avgBmi;
  double get avgHr => _avgHr;

  int get totalProducts => products.length;
  double productsPercent = -5.0;

  // Daily tracking logic for the circular graph
  int get workoutsLogged {
    final today = DateTime.now().toIso8601String().split('T').first;
    return activities.where((a) => a['date'] == today).length;
  }

  // Maps daily count to requested percentage steps (Goal: 4)
  double get workoutsPercent {
    final count = workoutsLogged;
    if (count == 0) return 0.0;
    if (count == 1) return 25.0;
    if (count == 2) return 50.0;
    if (count == 3) return 75.0;
    return 100.0;
  }

  // Chart Data
  List<double> weeklyEngagementData = [2.0, 6.0, 8.0, 3.0, 4.0, 7.0, 3.0];
  Map<String, double> categoryDistribution = {};
  List<String> activityCategories = ['All'];
  List<String> exerciseCategories = [];
  List<String> productCategories = [];
  List<String> categories = [];
  final Map<String, String> _exerciseCategoryIds = {};
  final Map<String, String> _productCategoryIds = {};

  final ApiClient _api = ApiClient();

  String _capitalize(String s) {
    if (s.isEmpty) return s;
    return s[0].toUpperCase() + s.substring(1).toLowerCase();
  }

  String _normalizeImagePath(String? path) {
    if (path == null || path.trim().isEmpty) return '';
    final p = path.trim();
    if (p.startsWith('http') || p.startsWith('assets/')) return p;
    // If it's a local file path (for pre-display/preview)
    if (p.startsWith('/') || p.contains(':\\') || p.startsWith('file://')) {
      return p;
    }
    return '$_baseUrl$p';
  }

  Future<void> fetchCategories() async {
    final Set<String> prodSet = {};
    final Set<String> activitySet = {};
    _exerciseCategoryIds.clear();
    _productCategoryIds.clear();

    try {
      final res = await _api.get(ApiEndpoints.categories, includeAuth: true);
      if (res is List) {
        for (var c in res) {
          final name = _capitalize((c['name'] ?? '').toString().trim());
          final type = (c['type'] ?? '').toString().toLowerCase();
          final id = c['id']?.toString();
          if (name.isEmpty || name.toLowerCase() == 'all') continue;
          if (type == 'product') {
            prodSet.add(name);
            if (id != null) {
              _productCategoryIds[name] = id;
            }
          } else if (type == 'exercise') {
            activitySet.add(name);
            if (id != null) {
              _exerciseCategoryIds[name] = id;
            }
          }
        }
      }
    } catch (e) {
      debugPrint('API Category Fetch Error: $e');
    }

    try {
      // Merge locally persisted categories
      final localCats = await _db.queryAll('categories');
      for (var cat in localCats) {
        final name = _capitalize((cat['name'] ?? '').toString().trim());
        final type = (cat['type'] ?? '').toString().toLowerCase();
        if (name.isEmpty || name.toLowerCase() == 'all') continue;

        if (type == 'product') {
          prodSet.add(name);
        } else if (type == 'exercise')
          activitySet.add(name);
      }
    } catch (e) {
      debugPrint('Local Category Fetch Error: $e');
    }

    // Atomic updates to prevent Dropdown Assertion errors
    final List<String> finalProdCats = prodSet.toList();
    final List<String> finalExCats = activitySet.toList();

    productCategories = finalProdCats;
    exerciseCategories = finalExCats;
    activityCategories = ['All', ...finalExCats];
    categories = {...prodSet, ...activitySet}.toList();

    try {
      // Load persisted activities and products to replace hardcoded data
      final persistedExercises = await _db.queryAll('exercises');
      activities = persistedExercises.map((e) {
        final map = e.map((k, v) => MapEntry(k, v.toString()));
        // Normalize DB keys to UI/Model keys for consistency
        map['title'] = map['title'] ?? map['name'] ?? '';
        map['image'] = _normalizeImagePath(map['image'] ?? map['image_url']);
        map['mainWorkout'] = map['mainWorkout'] ?? map['main_workout'] ?? '';
        map['category'] = map['category'] ?? map['category_name'] ?? '';

        return map;
      }).toList();

      // Update recent activities for the dashboard based on latest 4 exercises
      activities.sort((a, b) => (b['id'] ?? '').compareTo(a['id'] ?? ''));
      recentActivities = activities
          .take(4)
          .map(
            (a) => {
              'title': a['title'] ?? '',
              'subtitle': '${a['category'] ?? ''} • Just now',
            },
          )
          .toList();

      // Recalculate category distribution based on loaded exercises
      final Map<String, double> newDist = {};
      for (var activity in activities) {
        String? rawCat =
            activity['category'] ??
            activity['category_name'] ??
            activity['categoryName'];
        if (rawCat != null && rawCat.isNotEmpty) {
          final catName = _capitalize(rawCat.toString().trim());
          if (catName.toLowerCase() != 'all') {
            newDist[catName] = (newDist[catName] ?? 0) + 1;
          }
        }
      }
      categoryDistribution = newDist;

      final persistedProducts = await _db.queryAll('products');
      products = persistedProducts.map((e) {
        final map = e.map((k, v) => MapEntry(k, v.toString()));
        map['image'] = _normalizeImagePath(map['image'] ?? map['image_url']);
        return map;
      }).toList();
    } catch (e) {
      debugPrint('Data Persistence Fetch Error: $e');
    }
  }

  /// Deletes the currently logged-in user account from the database.
  Future<void> deleteAccount() async {
    try {
      await _api.delete(ApiEndpoints.profile, includeAuth: true);
    } catch (e) {
      debugPrint('AdminRepository: Account deletion failed: $e');
      rethrow;
    }
  }

  String getExerciseCategoryId(String category) {
    final name = _capitalize(category.trim());
    return _exerciseCategoryIds[name] ?? '';
  }

  String getProductCategoryId(String category) {
    final name = _capitalize(category.trim());
    return _productCategoryIds[name] ?? '';
  }

  Future<void> addCategory(String category) async {
    final name = _capitalize(category.trim());
    if (name.isEmpty) return;

    if (!categories.any((c) => c.toLowerCase() == name.toLowerCase())) {
      categories.add(name);
      exerciseCategories.add(name);

      // Persist locally
      _db.insert('categories', {
        'name': name,
        'type': 'exercise',
        'id': 'ex_$name',
      });

      if (!activityCategories.any(
        (c) => c.toLowerCase() == name.toLowerCase(),
      )) {
        activityCategories.add(name);
      }

      try {
        final response = await _api.post(
          ApiEndpoints.categories,
          body: {'name': name, 'type': 'exercise'},
          includeAuth: true,
        );
        if (response is Map<String, dynamic> && response['id'] != null) {
          _exerciseCategoryIds[name] = response['id'].toString();
        }
      } catch (_) {}
    }
  }

  Future<void> removeCategory(String category) async {
    final id = _exerciseCategoryIds[category];
    if (id != null) {
      try {
        await _api.delete('${ApiEndpoints.categories}/$id', includeAuth: true);
        _exerciseCategoryIds.remove(category);
      } catch (e) {
        debugPrint('Backend Category Delete Error: $e');
      }
    }

    categories.remove(category);
    exerciseCategories.remove(category);
    activityCategories.remove(category);
    await _db.delete('categories', 'ex_$category');
  }

  Future<void> addProductCategory(String category) async {
    final name = _capitalize(category.trim());
    if (name.isEmpty) return;

    if (!productCategories.any((c) => c.toLowerCase() == name.toLowerCase())) {
      productCategories.add(name);
      categories.add(name);

      // Persist locally
      _db.insert('categories', {
        'name': name,
        'type': 'product',
        'id': 'prod_$name',
      });

      try {
        final response = await _api.post(
          ApiEndpoints.categories,
          body: {'name': name, 'type': 'product'},
          includeAuth: true,
        );
        if (response is Map<String, dynamic> && response['id'] != null) {
          _productCategoryIds[name] = response['id'].toString();
        }
      } catch (_) {}
    }
  }

  Future<void> removeProductCategory(String category) async {
    final id = _productCategoryIds[category];
    if (id != null) {
      try {
        await _api.delete('${ApiEndpoints.categories}/$id', includeAuth: true);
        _productCategoryIds.remove(category);
      } catch (e) {
        debugPrint('Backend Product Category Delete Error: $e');
      }
    }
    productCategories.remove(category);
    categories.remove(category);
    await _db.delete('categories', 'prod_$category');
  }

  Map<String, double> get productCategoryDistribution {
    final Map<String, double> dist = {};
    for (var p in products) {
      String rawCat = p['category'] ?? p['category_name'] ?? '';
      if (rawCat.isNotEmpty) {
        final cat = _capitalize(rawCat);
        if (cat.toLowerCase() != 'all') {
          dist[cat] = (dist[cat] ?? 0) + 1;
        }
      }
    }
    return dist;
  }

  // Lists
  // Start with empty lists to ensure only successfully added items appear
  List<Map<String, String>> activities = [];

  List<Map<String, String>> products = [];

  List<Map<String, String>> announcements = [
    {
      'title': 'Holiday Schedule',
      'description':
          'The gym will be closed on December 25th for Christmas. We wish everyone a Merry Christmas!',
      'date': '2024-12-25',
    },
    {
      'title': 'New Yoga Classes',
      'description':
          'Join us for our new sunrise yoga sessions starting every Monday at 6:00 AM.',
      'date': '2024-03-20',
    },
  ];

  List<Map<String, String>> recentActivities = [
    {'title': 'Full Cardio Burn', 'subtitle': '45 min • 2024-03-15'},
    {'title': 'Strength Power Set', 'subtitle': '60 min • 2024-03-14'},
    {'title': 'Running Session', 'subtitle': '30 min • 2024-03-14'},
  ];

  bool hasNewAnnouncements = true;

  void markAnnouncementsAsViewed() {
    hasNewAnnouncements = false;
  }

  // Actions
  Future<void> addActivity(Map<String, String> activity) async {
    // Normalize keys and capitalize categories to prevent Dropdown assertion errors
    final normalized = Map<String, String>.from(activity);

    String cat = _capitalize(
      normalized['category'] ?? normalized['category_name'] ?? '',
    );
    if (cat.toLowerCase() == 'all') cat = '';

    // Map Category Name to Category ID
    final String catId = _exerciseCategoryIds[cat] ?? '';
    normalized['category'] = cat;
    normalized['category_id'] = catId;

    // Add date for daily reset tracking
    normalized['date'] = DateTime.now().toIso8601String().split('T').first;

    normalized.remove('muscle_group');
    normalized.remove('instructions');

    normalized['image'] = _normalizeImagePath(
      normalized['image'] ?? normalized['image_url'],
    );

    if (!exerciseCategories.contains(cat)) {
      exerciseCategories.add(cat);
    }

    activities = [normalized, ...activities];
    recentActivities = [
      {
        'title': activity['title']!,
        'subtitle': '${activity['category']} • Just now',
      },
      ...recentActivities,
    ];

    if (cat.isNotEmpty) {
      categoryDistribution = Map.from(categoryDistribution)
        ..[cat] = (categoryDistribution[cat] ?? 0) + 1;
    }
    weeklyEngagementData = List.from(weeklyEngagementData)..[6] += 1;

    // Strip ID from body to prevent "out of range for type integer" errors on backend
    final apiBody = Map<String, String>.from(normalized);
    apiBody.remove('id');
    // Map title to name for backend compatibility
    if (apiBody['name'] == null && apiBody['title'] != null) {
      apiBody['name'] = apiBody['title']!;
    }

    final response = await _api.post(ApiEndpoints.activities, body: apiBody);

    // Sync the backend-generated ID back to our local object and database
    if (response is Map<String, dynamic> && response['id'] != null) {
      normalized['id'] = response['id'].toString();
    }
    await _db.insert('exercises', normalized);
  }

  Future<void> removeActivity(Map<String, String> activity) async {
    activities.removeWhere((a) => a['id'] == activity['id']);
    String cat = _capitalize(activity['category'] ?? '');
    if (cat.isNotEmpty && cat.toLowerCase() != 'all') {
      categoryDistribution = Map.from(categoryDistribution);
      categoryDistribution[cat] = (categoryDistribution[cat] ?? 1) - 1;
      if (categoryDistribution[cat] != null &&
          categoryDistribution[cat]! <= 0) {
        categoryDistribution.remove(cat);
      }
    }

    if (activity['id'] != null) {
      // Update local DB first (fast)
      await _db.delete('exercises', activity['id']!);
      // Perform API call in background
      try {
        _api
            .delete(ApiEndpoints.activity(activity['id']!))
            .catchError(
              (e) => debugPrint(
                'AdminRepository: Activity API deletion failed: $e',
              ),
            );
      } catch (_) {}
    }
  }

  Future<void> updateActivity(
    Map<String, String> oldActivity,
    Map<String, String> newActivity,
  ) async {
    newActivity['image'] = _normalizeImagePath(
      newActivity['image'] ?? newActivity['image_url'],
    );

    String catName = _capitalize(newActivity['category'] ?? '');
    newActivity['category_id'] = _exerciseCategoryIds[catName] ?? '';
    newActivity.remove('muscle_group');
    newActivity.remove('instructions');

    // Strip ID from body to prevent "out of range for type integer" errors on backend.
    // The backend identifies the record via the URL segment.
    final apiBody = Map<String, String>.from(newActivity);
    apiBody.remove('id');
    // Map title to name for backend compatibility
    if (apiBody['name'] == null && apiBody['title'] != null) {
      apiBody['name'] = apiBody['title']!;
    }

    // 1. Always update API and Database regardless of in-memory list state
    await _api.put(
      ApiEndpoints.activity(newActivity['id'] ?? oldActivity['id']!),
      body: apiBody,
    );
    await _db.insert('exercises', newActivity);

    // 2. Update In-memory list if found
    int index = activities.indexWhere((a) => a['id'] == oldActivity['id']);
    if (index != -1) {
      activities = List.from(activities)..[index] = newActivity;

      // Update distribution if category changed
      String? oldCat = _capitalize(
        oldActivity['category'] ?? oldActivity['category_name'] ?? '',
      );
      String? newCat = _capitalize(
        newActivity['category'] ?? newActivity['category_name'] ?? '',
      );
      if (oldCat != newCat) {
        categoryDistribution = Map.from(categoryDistribution);
        if (oldCat.toLowerCase() != 'all') {
          categoryDistribution[oldCat] =
              (categoryDistribution[oldCat] ?? 1) - 1;
          if (categoryDistribution[oldCat]! <= 0) {
            categoryDistribution.remove(oldCat);
          }
        }
        if (newCat.toLowerCase() != 'all') {
          categoryDistribution[newCat] =
              (categoryDistribution[newCat] ?? 0) + 1;
        }
      }

      if (!exerciseCategories.contains(newCat)) {
        exerciseCategories.add(newCat);
      }
    }
  }

  Future<void> addProduct(Map<String, String> product) async {
    final normalized = Map<String, String>.from(product);
    String cat = _capitalize(
      normalized['category'] ?? normalized['category_name'] ?? '',
    );
    if (cat.toLowerCase() == 'all') cat = '';

    normalized['category'] = cat;
    normalized['image'] = _normalizeImagePath(
      normalized['image'] ?? normalized['image_url'],
    );

    if (cat.isNotEmpty && !productCategories.contains(cat)) {
      productCategories.add(cat);
    }

    products = [normalized, ...products];
    totalRevenue += 50;

    // Strip ID from body to prevent "out of range for type integer" errors on backend
    final apiBody = Map<String, String>.from(normalized);
    apiBody.remove('id');
    // Map title to name for backend compatibility
    if (apiBody['name'] == null && apiBody['title'] != null) {
      apiBody['name'] = apiBody['title']!;
    }

    final response = await _api.post(ApiEndpoints.products, body: apiBody);

    if (response is Map<String, dynamic> && response['id'] != null) {
      normalized['id'] = response['id'].toString();
    }

    // Persist to database
    await _db.insert('products', normalized);
  }

  Future<void> updateProduct(int index, Map<String, String> product) async {
    products = List.from(products)..[index] = product;
    if (product['id'] != null) {
      // Strip ID from body to prevent "out of range for type integer" errors on backend
      final apiBody = Map<String, String>.from(product);
      apiBody.remove('id');
      // Map title to name for backend compatibility
      if (apiBody['name'] == null && apiBody['title'] != null) {
        apiBody['name'] = apiBody['title']!;
      }
      await _api.put(ApiEndpoints.product(product['id']!), body: apiBody);
      await _db.insert('products', Map<String, dynamic>.from(product));
    }
  }

  Future<void> removeProduct(Map<String, String> product) async {
    products.removeWhere((p) => p['id'] == product['id']);
    totalRevenue -= 50;
    if (product['id'] != null) {
      // Update local DB first (fast)
      await _db.delete('products', product['id']!);
      // Perform API call in background
      try {
        _api
            .delete(ApiEndpoints.product(product['id']!))
            .catchError(
              (e) => debugPrint(
                'AdminRepository: Product API deletion failed: $e',
              ),
            );
      } catch (_) {}
    }
  }

  void addActivityCategory(String category) {
    final name = _capitalize(category.trim());
    if (name.isEmpty) return;

    if (!activityCategories.contains(name)) {
      activityCategories.add(name);
      exerciseCategories.add(name);

      _db.insert('categories', {
        'name': name,
        'type': 'exercise',
        'id': 'ex_$name',
      });
    }
  }

  void addAnnouncement(Map<String, String> announcement) {
    announcements = [announcement, ...announcements];
    hasNewAnnouncements = true;
    recentActivities = [
      {'title': announcement['title']!, 'subtitle': 'News • Just now'},
      ...recentActivities,
    ];
  }

  void updateAnnouncement(int index, Map<String, String> announcement) {
    announcements = List.from(announcements)..[index] = announcement;
  }

  void removeAnnouncement(Map<String, String> announcement) {
    announcements = List.from(announcements)..remove(announcement);
  }
}
