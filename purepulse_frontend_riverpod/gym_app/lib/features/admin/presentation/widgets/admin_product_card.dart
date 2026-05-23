// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/image_utils.dart';

class AdminProductCard extends StatelessWidget {
  final String title;
  final String description;
  final String category;
  final String imageUrl;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const AdminProductCard({
    super.key,
    required this.title,
    required this.description,
    required this.category,
    required this.imageUrl,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    Widget imageWidget = SafeImage(
      imageUrl: imageUrl,
      fit: BoxFit.cover,
      alignment: Alignment.center,
    );

    return Container(
      height: 160,
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: const Color(0xFFE7ECF7).withValues(alpha: 0.32),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Image
          ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(16),
              bottomLeft: Radius.circular(16),
            ),
            child: Container(
              width: 140,
              padding: EdgeInsets.zero,
              color: Colors.grey[100],
              child: SizedBox.expand(child: imageWidget),
            ),
          ),
          const SizedBox(width: 16),
          // Details
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 14, right: 14, bottom: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      category.toUpperCase(),
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontSize: 8,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    title,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 13,
                      height: 1.4,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const Spacer(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      InkWell(
                        onTap: onEdit,
                        child: Row(
                          children: const [
                            Icon(
                              Icons.edit,
                              size: 14,
                              color: AppColors.primary,
                            ),
                            SizedBox(width: 6),
                            Text(
                              'Edit',
                              style: TextStyle(
                                color: AppColors.primary,
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 20),
                      InkWell(
                        onTap: onDelete,
                        child: Row(
                          children: const [
                            Icon(
                              Icons.delete_outline,
                              size: 14,
                              color: Colors.red,
                            ),
                            SizedBox(width: 6),
                            Text(
                              'Delete',
                              style: TextStyle(
                                color: Colors.red,
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
