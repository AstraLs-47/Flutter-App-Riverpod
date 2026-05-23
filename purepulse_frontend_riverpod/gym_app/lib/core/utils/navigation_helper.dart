// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:go_router/go_router.dart';

// Project imports:
import '../constants/route_constants.dart';

enum BottomNavItem { dashboard, tracking, exercises, products, profile }

class NavigationHelper {
  NavigationHelper._();

  static const Map<BottomNavItem, String> bottomNavRoutes = {
    BottomNavItem.dashboard: RouteConstants.dashboardName,
    BottomNavItem.tracking: RouteConstants.trackingName,
    BottomNavItem.exercises: RouteConstants.exercisesName,
    BottomNavItem.products: RouteConstants.productsName,
    BottomNavItem.profile: RouteConstants.profileName,
  };

  static void onBottomNavTapped(BuildContext context, BottomNavItem item, BottomNavItem currentItem) {
    if (item == currentItem) return;
    
    final routeName = bottomNavRoutes[item];
    if (routeName != null) {
      context.goNamed(routeName);
    }
  }
}
