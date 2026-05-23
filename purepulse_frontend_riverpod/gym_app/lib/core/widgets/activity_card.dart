// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import '../theme/app_colors.dart';
import '../utils/image_utils.dart';
import 'custom_card.dart';

class ActivityCard extends StatelessWidget {
  final String title;
  final String description;
  final String imageUrl;
  final AlignmentGeometry alignment;
  final VoidCallback onTap;
  final String actionText;

  const ActivityCard({
    super.key,
    required this.title,
    required this.description,
    required this.imageUrl,
    this.alignment = Alignment.center,
    required this.onTap,
    this.actionText = 'View Workout Set',
  });

  @override
  Widget build(BuildContext context) {
    return CustomCard(
      padding: EdgeInsets.zero,
      hasShadow: true,
      border: Border.all(color: Colors.grey.withValues(alpha: 0.1)),
      child: SizedBox(
        height: double.infinity,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AspectRatio(
              aspectRatio:
                  1.15, // Slightly shorter image to give text more room
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(16),
                ),
                child: Container(
                  color: Colors.grey[100],
                  child: SafeImage(
                    imageUrl: imageUrl,
                    fit: BoxFit.cover,
                    alignment: alignment,
                  ),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.textSecondary,
                        height: 1.4,
                      ),
                    ),
                    const Spacer(),
                    GestureDetector(
                      onTap: onTap,
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 12.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Text(
                              actionText,
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: AppColors.primary,
                              ),
                            ),
                            const SizedBox(width: 4),
                            const Icon(
                              Icons.arrow_forward_ios,
                              size: 10,
                              color: AppColors.primary,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
