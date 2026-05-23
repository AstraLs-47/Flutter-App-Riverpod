// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import '../theme/app_colors.dart';
import '../utils/navigation_helper.dart';

class UserBottomNav extends StatelessWidget {
  final BottomNavItem currentItem;

  const UserBottomNav({
    super.key,
    required this.currentItem,
  });

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentItem.index,
      onTap: (index) {
        if (index >= 0 && index < BottomNavItem.values.length) {
          NavigationHelper.onBottomNavTapped(
              context, BottomNavItem.values[index], currentItem);
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
          icon: Icon(Icons.show_chart),
          label: 'Tracking',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.fitness_center),
          label: 'Exercises',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.shopping_bag_outlined),
          activeIcon: Icon(Icons.shopping_bag),
          label: 'Product',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person_outline),
          activeIcon: Icon(Icons.person),
          label: 'Profile',
        ),
      ],
    );
  }
}
