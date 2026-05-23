// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import '../constants/app_constants.dart';
import '../theme/app_colors.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final bool isOutlined;
  final double? width;

  const CustomButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isOutlined = false,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    final textStyle = const TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w600,
    );

    final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(AppConstants.buttonBorderRadius),
    );

    return SizedBox(
      width: width ?? double.infinity,
      height: AppConstants.buttonHeight,
      child: isOutlined
          ? OutlinedButton(
              onPressed: onPressed,
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primary,
                side: const BorderSide(color: AppColors.primary),
                shape: shape,
              ),
              child: Text(text, style: textStyle),
            )
          : ElevatedButton(
              onPressed: onPressed,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: shape,
              ),
              child: Text(text, style: textStyle),
            ),
    );
  }
}
