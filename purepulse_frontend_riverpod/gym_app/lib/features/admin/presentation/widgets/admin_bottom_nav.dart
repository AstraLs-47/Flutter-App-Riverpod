// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:go_router/go_router.dart';

// Project imports:
import '../../../../core/constants/route_constants.dart';
import '../../../../core/theme/app_colors.dart';

class AdminBottomNav extends StatelessWidget {
  final int currentIndex;

  const AdminBottomNav({
    super.key,
    required this.currentIndex,
  });

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: (index) {
        if (index == 0) {
          context.goNamed(RouteConstants.adminName);
        } else if (index == 1) {
          context.goNamed(RouteConstants.adminActivitiesName);
        } else if (index == 2) {
          context.goNamed(RouteConstants.adminProductsName);
        } else if (index == 3) {
          context.goNamed(RouteConstants.adminAnnouncementsName);
        }
      },
      selectedItemColor: AppColors.primary,
      unselectedItemColor: AppColors.textSecondary,
      showUnselectedLabels: true,
      selectedLabelStyle: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
      unselectedLabelStyle: const TextStyle(fontSize: 10),
      type: BottomNavigationBarType.fixed,
      backgroundColor: Colors.white,
      elevation: 8,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.grid_view_outlined),
          activeIcon: Icon(Icons.grid_view),
          label: 'Dashboard',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.fitness_center_outlined),
          activeIcon: Icon(Icons.fitness_center),
          label: 'Activities',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.shopping_bag_outlined),
          activeIcon: Icon(Icons.shopping_bag),
          label: 'Products',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.campaign_outlined),
          activeIcon: Icon(Icons.campaign),
          label: 'Announce',
        ),
      ],
    );
  }
}
