// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../data/database_helper.dart';
import '../data/token_storage.dart';
import '../network/api_client.dart';

// Domain Repositories
import '../domain/repositories/i_auth_repository.dart';
import '../domain/repositories/i_product_repository.dart';
import '../domain/repositories/i_exercise_repository.dart';
import '../domain/repositories/i_announcement_repository.dart';
import '../domain/repositories/i_health_repository.dart';
import '../domain/repositories/i_progress_repository.dart';
import '../domain/repositories/i_admin_repository.dart';

// Data Repositories
import '../../features/auth/data/auth_repository.dart';
import '../../features/products/data/product_repository.dart';
import '../../features/exercises/data/exercise_repository.dart';
import '../../features/announcement/data/announcement_repository.dart';
import '../../features/progress/data/health_repository.dart';
import '../../features/workout/data/progress_repository.dart';
import '../../features/admin/data/admin_repository.dart';

// Stores
import '../../features/progress/data/health_store.dart';
import '../../features/workout/data/workout_store.dart';

// Use Cases
import '../../features/auth/application/sign_in_use_case.dart';
import '../../features/auth/application/sign_up_use_case.dart';
import '../../features/auth/application/sign_out_use_case.dart';
import '../../features/auth/application/check_auth_status_use_case.dart';

import '../../features/products/application/get_products_use_case.dart';
import '../../features/products/application/create_product_use_case.dart';
import '../../features/products/application/update_product_use_case.dart';
import '../../features/products/application/delete_product_use_case.dart';

import '../../features/exercises/application/get_exercises_use_case.dart';
import '../../features/exercises/application/create_exercise_use_case.dart';
import '../../features/exercises/application/update_exercise_use_case.dart';
import '../../features/exercises/application/delete_exercise_use_case.dart';

import '../../features/announcement/application/get_announcements_use_case.dart';
import '../../features/announcement/application/create_announcement_use_case.dart';
import '../../features/announcement/application/update_announcement_use_case.dart';
import '../../features/announcement/application/delete_announcement_use_case.dart';

import '../../features/progress/application/get_health_records_use_case.dart';
import '../../features/progress/application/add_health_record_use_case.dart';

import '../../features/workout/application/get_workout_entries_use_case.dart';
import '../../features/workout/application/create_workout_entry_use_case.dart';
import '../../features/workout/application/update_workout_entry_use_case.dart';
import '../../features/workout/application/delete_workout_entry_use_case.dart';

import '../../features/dashboard/application/get_dashboard_stats_use_case.dart';
import '../../features/admin/application/get_admin_dashboard_stats_use_case.dart';

// Infrastructure Providers
final tokenStorageProvider = Provider<TokenStorage>((ref) => TokenStorage());
final databaseHelperProvider = Provider<DatabaseHelper>((ref) => DatabaseHelper());

final apiClientProvider = Provider<ApiClient>((ref) {
  final tokenStorage = ref.watch(tokenStorageProvider);
  return ApiClient(tokenStorage: tokenStorage);
});

// Stores Providers
final healthStoreProvider = Provider<HealthStore>((ref) => HealthStore());
final workoutStoreProvider = Provider<WorkoutStore>((ref) => WorkoutStore());

// Repository Providers
final authRepositoryProvider = Provider<IAuthRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  final tokenStorage = ref.watch(tokenStorageProvider);
  final dbHelper = ref.watch(databaseHelperProvider);
  return AuthRepository(apiClient: apiClient, tokenStorage: tokenStorage, dbHelper: dbHelper);
});

final productRepositoryProvider = Provider<IProductRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  final dbHelper = ref.watch(databaseHelperProvider);
  return ProductRepository(apiClient: apiClient, dbHelper: dbHelper);
});

final exerciseRepositoryProvider = Provider<IExerciseRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  final dbHelper = ref.watch(databaseHelperProvider);
  return ExerciseRepository(apiClient: apiClient, dbHelper: dbHelper);
});

final announcementRepositoryProvider = Provider<IAnnouncementRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  final dbHelper = ref.watch(databaseHelperProvider);
  return AnnouncementRepository(apiClient: apiClient, dbHelper: dbHelper);
});

final healthRepositoryProvider = Provider<IHealthRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  final dbHelper = ref.watch(databaseHelperProvider);
  return HealthRepository(apiClient: apiClient, dbHelper: dbHelper);
});

final progressRepositoryProvider = Provider<IProgressRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  final dbHelper = ref.watch(databaseHelperProvider);
  return ProgressRepository(apiClient: apiClient, dbHelper: dbHelper);
});

final adminRepositoryProvider = Provider<IAdminRepository>((ref) {
  return AdminRepository();
});

// Auth Use Cases Providers
final signInUseCaseProvider = Provider<SignInUseCase>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return SignInUseCase(repository);
});

final signUpUseCaseProvider = Provider<SignUpUseCase>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return SignUpUseCase(repository);
});

final signOutUseCaseProvider = Provider<SignOutUseCase>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return SignOutUseCase(repository);
});

final checkAuthStatusUseCaseProvider = Provider<CheckAuthStatusUseCase>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return CheckAuthStatusUseCase(repository);
});

// Product Use Cases Providers
final getProductsUseCaseProvider = Provider<GetProductsUseCase>((ref) {
  final repository = ref.watch(productRepositoryProvider);
  return GetProductsUseCase(repository);
});

final createProductUseCaseProvider = Provider<CreateProductUseCase>((ref) {
  final repository = ref.watch(productRepositoryProvider);
  return CreateProductUseCase(repository);
});

final updateProductUseCaseProvider = Provider<UpdateProductUseCase>((ref) {
  final repository = ref.watch(productRepositoryProvider);
  return UpdateProductUseCase(repository);
});

final deleteProductUseCaseProvider = Provider<DeleteProductUseCase>((ref) {
  final repository = ref.watch(productRepositoryProvider);
  return DeleteProductUseCase(repository);
});

// Exercise Use Cases Providers
final getExercisesUseCaseProvider = Provider<GetExercisesUseCase>((ref) {
  final repository = ref.watch(exerciseRepositoryProvider);
  return GetExercisesUseCase(repository);
});

final createExerciseUseCaseProvider = Provider<CreateExerciseUseCase>((ref) {
  final repository = ref.watch(exerciseRepositoryProvider);
  return CreateExerciseUseCase(repository);
});

final updateExerciseUseCaseProvider = Provider<UpdateExerciseUseCase>((ref) {
  final repository = ref.watch(exerciseRepositoryProvider);
  return UpdateExerciseUseCase(repository);
});

final deleteExerciseUseCaseProvider = Provider<DeleteExerciseUseCase>((ref) {
  final repository = ref.watch(exerciseRepositoryProvider);
  return DeleteExerciseUseCase(repository);
});

// Announcement Use Cases Providers
final getAnnouncementsUseCaseProvider = Provider<GetAnnouncementsUseCase>((ref) {
  final repository = ref.watch(announcementRepositoryProvider);
  return GetAnnouncementsUseCase(repository);
});

final createAnnouncementUseCaseProvider = Provider<CreateAnnouncementUseCase>((ref) {
  final repository = ref.watch(announcementRepositoryProvider);
  return CreateAnnouncementUseCase(repository);
});

final updateAnnouncementUseCaseProvider = Provider<UpdateAnnouncementUseCase>((ref) {
  final repository = ref.watch(announcementRepositoryProvider);
  return UpdateAnnouncementUseCase(repository);
});

final deleteAnnouncementUseCaseProvider = Provider<DeleteAnnouncementUseCase>((ref) {
  final repository = ref.watch(announcementRepositoryProvider);
  return DeleteAnnouncementUseCase(repository);
});

// Health Use Cases Providers
final getHealthRecordsUseCaseProvider = Provider<GetHealthRecordsUseCase>((ref) {
  final repository = ref.watch(healthRepositoryProvider);
  return GetHealthRecordsUseCase(repository);
});

final addHealthRecordUseCaseProvider = Provider<AddHealthRecordUseCase>((ref) {
  final repository = ref.watch(healthRepositoryProvider);
  return AddHealthRecordUseCase(repository);
});

// Workout Use Cases Providers
final getWorkoutEntriesUseCaseProvider = Provider<GetWorkoutEntriesUseCase>((ref) {
  final repository = ref.watch(progressRepositoryProvider);
  return GetWorkoutEntriesUseCase(repository);
});

final createWorkoutEntryUseCaseProvider = Provider<CreateWorkoutEntryUseCase>((ref) {
  final repository = ref.watch(progressRepositoryProvider);
  return CreateWorkoutEntryUseCase(repository);
});

final updateWorkoutEntryUseCaseProvider = Provider<UpdateWorkoutEntryUseCase>((ref) {
  final repository = ref.watch(progressRepositoryProvider);
  return UpdateWorkoutEntryUseCase(repository);
});

final deleteWorkoutEntryUseCaseProvider = Provider<DeleteWorkoutEntryUseCase>((ref) {
  final repository = ref.watch(progressRepositoryProvider);
  return DeleteWorkoutEntryUseCase(repository);
});

// Dashboard Use Case Provider
final getDashboardStatsUseCaseProvider = Provider<GetDashboardStatsUseCase>((ref) {
  final healthRepo = ref.watch(healthRepositoryProvider);
  final progressRepo = ref.watch(progressRepositoryProvider);
  final announcementRepo = ref.watch(announcementRepositoryProvider);
  final adminRepo = ref.watch(adminRepositoryProvider);
  final healthStore = ref.watch(healthStoreProvider);
  final workoutStore = ref.watch(workoutStoreProvider);
  return GetDashboardStatsUseCase(
    healthRepo: healthRepo,
    progressRepo: progressRepo,
    announcementRepo: announcementRepo,
    adminRepo: adminRepo,
    healthStore: healthStore,
    workoutStore: workoutStore,
  );
});

final getAdminDashboardStatsUseCaseProvider = Provider<GetAdminDashboardStatsUseCase>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return GetAdminDashboardStatsUseCase(apiClient);
});
