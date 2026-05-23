// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import '../theme/app_colors.dart';
import 'custom_card.dart';

class StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color? iconColor;

  const StatCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return CustomCard(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                value,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: (iconColor ?? AppColors.primary).withValues(
                    alpha: 0.1,
                  ),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  color: iconColor ?? AppColors.primary,
                  size: 20,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
