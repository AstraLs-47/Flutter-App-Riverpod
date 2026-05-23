// Package imports:
import 'package:flutter/foundation.dart';

class ApiEndpoints {
  static String get baseUrl {
    if (kIsWeb) {
      return 'http://localhost:3000/api';
    }
    if (defaultTargetPlatform == TargetPlatform.android) {
      return 'http://10.0.2.2:3000/api';
    }
    return 'http://localhost:3000/api';
  }

  // Auth
  static String get login => '$baseUrl/auth/signin';
  static String get register => '$baseUrl/auth/signup';
  static String get profile => '$baseUrl/auth/me';
  static String get signout => '$baseUrl/auth/signout';
  static String get onboard => '$baseUrl/user/onboard';
  static String get deleteAccount => '$baseUrl/user/account';

  // Products
  static String get products => '$baseUrl/products';
  static String product(String id) => '$products/$id';

  // Activities / Exercises
  static String get activities => '$baseUrl/exercises';
  static String activity(String id) => '$activities/$id';

  // Announcements
  static String get announcements => '$baseUrl/announcements';
  static String announcement(String id) => '$announcements/$id';

  // Progress/Stats
  static String get stats => '$baseUrl/progress/stats';
  static String get progress => '$baseUrl/progress';
  static String progressId(String id) => '$progress/$id';

  // Health Records
  static String get healthRecords => '$baseUrl/health';
  static String healthRecordId(String id) => '$healthRecords/$id';
  static String get healthLatest => '$healthRecords/latest';

  // Categories
  static String get categories => '$baseUrl/categories';
  static String get uploads => '$baseUrl/uploads';

  // Admin Dashboard
  static String get adminDashboard => '$baseUrl/admin/dashboard';
}
