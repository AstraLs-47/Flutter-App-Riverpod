class RouteConstants {
  RouteConstants._();

  // Root
  static const String root = '/';
  static const String rootName = 'root';

  // Auth
  static const String signIn = '/sign-in';
  static const String signInName = 'signIn';
  static const String signUp = '/sign-up';
  static const String signUpName = 'signUp';
  static const String onboarding = '/onboarding';
  static const String onboardingName = 'onboarding';

  // Main
  static const String dashboard = '/dashboard';
  static const String dashboardName = 'dashboard';
  static const String tracking = '/tracking';
  static const String trackingName = 'tracking';
  static const String exercises = '/exercises';
  static const String exercisesName = 'exercises';
  static const String products = '/products';
  static const String productsName = 'products';
  static const String profile = '/profile';
  static const String profileName = 'profile';
  static const String announcements = '/announcements';
  static const String announcementsName = 'announcements';
  static const String contactUs = '/contact-us';
  static const String contactUsName = 'contactUs';
  static const String exerciseDetail = '/exercise-detail';
  static const String exerciseDetailName = 'exerciseDetail';

  // Tracking (relative)
  static const String trackingAddRel = 'add';
  static const String trackingAddName = 'trackingAdd';
  static const String trackingEditRel = 'edit';
  static const String trackingEditName = 'trackingEdit';

  // Admin base
  static const String admin = '/admin';
  static const String adminName = 'admin';

  // Admin (relative)
  static const String adminActivitiesRel = 'activities';
  static const String adminActivitiesName = 'adminActivities';
  static const String adminProductsRel = 'products';
  static const String adminProductsName = 'adminProducts';
  static const String adminAnnouncementsRel = 'announcements';
  static const String adminAnnouncementsName = 'adminAnnouncements';

  // Full paths (for backward compatibility if needed, but goNamed uses names)
  static const String trackingAdd = '$tracking/$trackingAddRel';
  static const String trackingEdit = '$tracking/$trackingEditRel';
  static const String adminActivities = '$admin/$adminActivitiesRel';
  static const String adminProducts = '$admin/$adminProductsRel';
  static const String adminAnnouncements = '$admin/$adminAnnouncementsRel';
}