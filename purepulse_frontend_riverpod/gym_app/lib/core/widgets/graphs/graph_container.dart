// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import '../../theme/app_colors.dart';

class GraphContainer extends StatelessWidget {
  final String title;
  final Widget child;
  final Widget? trailing;

  const GraphContainer({
    super.key,
    required this.title,
    required this.child,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: const Color(0xFFF1F1F1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (title.isNotEmpty) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                    letterSpacing: 0.5,
                  ),
                ),
                if (trailing != null) ...[trailing!],
              ],
            ),
            const SizedBox(height: 24),
          ],
          child,
        ],
      ),
    );
  }
}
