// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:go_router/go_router.dart';

// Project imports:
import '../../features/admin/presentation/screens/admin_activities_screen.dart';
import '../../features/admin/presentation/screens/admin_announcements_screen.dart';
import '../../features/admin/presentation/screens/admin_products_screen.dart';
import '../../features/admin/presentation/screens/command_center_screen.dart';
import '../../features/announcement/presentation/screens/announcements_screen.dart';
import '../../features/auth/presentation/screens/landing_screen.dart';
import '../../features/auth/presentation/screens/onboarding_screens.dart';
import '../../features/auth/presentation/screens/sign_in_screen.dart';
import '../../features/auth/presentation/screens/sign_up_screen.dart';
import '../../features/dashboard/presentation/screens/home_screen.dart';
import '../../features/exercises/presentation/screens/exercise_detail_screen.dart';
import '../../features/exercises/presentation/screens/exercises_screen.dart';
import '../../features/products/presentation/screens/products_screen.dart';
import '../../features/profile/presentation/screens/contact_us_screen.dart';
import '../../features/profile/presentation/screens/profile_screen.dart';
import '../../features/workout/presentation/screens/add_workout_screen.dart';
import '../../features/workout/presentation/screens/edit_workout_screen.dart';
import '../../features/workout/presentation/screens/tracking_screen.dart';
import '../constants/route_constants.dart';

class AppRouter {
  // Private constructor to prevent instantiation
  AppRouter._();

  static final GoRouter router = GoRouter(
    initialLocation: RouteConstants.root,
    errorBuilder: (context, state) => const Scaffold(
      body: Center(
        child: Text('Page not found'),
      ),
    ),
    routes: [
      //Root
      GoRoute(
        path: RouteConstants.root,
        name: RouteConstants.rootName,
        builder: (context, state) => const LandingScreen(),
      ), 

      //Auth
      GoRoute(
        path: RouteConstants.signIn,
        name: RouteConstants.signInName,
        builder: (context, state) => const SignInScreen(),
      ),
      GoRoute(
        path: RouteConstants.signUp,
        name: RouteConstants.signUpName,
        builder: (context, state) => const SignUpScreen(),
      ),
      GoRoute(
        path: RouteConstants.onboarding,
        name: RouteConstants.onboardingName,
        builder: (context, state) => const OnboardingFlow(),
      ),

      //Main
      GoRoute(
        path: RouteConstants.dashboard,
        name: RouteConstants.dashboardName,
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: RouteConstants.announcements,
        name: RouteConstants.announcementsName,
        builder: (context, state) => const AnnouncementsScreen(),
      ),
      GoRoute(
        path: RouteConstants.contactUs,
        name: RouteConstants.contactUsName,
        builder: (context, state) => const ContactUsScreen(),
      ),
      GoRoute(
        path: RouteConstants.exerciseDetail,
        name: RouteConstants.exerciseDetailName,
        builder: (context, state) => ExerciseDetailScreen(
          exercise: state.extra as Map<String, String>,
        ),
      ),
      GoRoute(
        path: RouteConstants.profile,
        name: RouteConstants.profileName,
        builder: (context, state) => const ProfileScreen(),
      ),
      
      // Features
      GoRoute(
        path: RouteConstants.exercises,
        name: RouteConstants.exercisesName,
        builder: (context, state) => const ExercisesScreen(),
      ),
      GoRoute(
        path: RouteConstants.products,
        name: RouteConstants.productsName,
        builder: (context, state) => const ProductsScreen(),
      ),

      // Tracking Routes
      GoRoute(
        path: RouteConstants.tracking,
        name: RouteConstants.trackingName,
        builder: (context, state) => const TrackingScreen(),
        routes: [
          GoRoute(
            path: RouteConstants.trackingAddRel,
            name: RouteConstants.trackingAddName,
            builder: (context, state) => const AddWorkoutScreen(),
          ),
          GoRoute(
            path: RouteConstants.trackingEditRel,
            name: RouteConstants.trackingEditName,
            builder: (context, state) => const EditWorkoutScreen(),
          ),
        ],
      ),

      //Admin
      GoRoute(
        path: RouteConstants.admin,
        name: RouteConstants.adminName,
        builder: (context, state) => const CommandCenterScreen(),
        routes: [
          GoRoute(
            path: RouteConstants.adminActivitiesRel,
            name: RouteConstants.adminActivitiesName,
            builder: (context, state) => const AdminActivitiesScreen(),
          ),
          GoRoute(
            path: RouteConstants.adminProductsRel,
            name: RouteConstants.adminProductsName,
            builder: (context, state) => const AdminProductsScreen(),
          ),
          GoRoute(
            path: RouteConstants.adminAnnouncementsRel,
            name: RouteConstants.adminAnnouncementsName,
            builder: (context, state) => const AdminAnnouncementsScreen(),
          ),
        ],
      ),
    ],
  );
}
