// Flutter imports:
import 'package:flutter/material.dart';

class CustomCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final Color? color;
  final double borderRadius;
  final double? width;
  final double? height;
  final bool hasShadow;
  final Border? border;

  const CustomCard({
    super.key,
    required this.child,
    this.padding,
    this.color,
    this.borderRadius = 16.0,
    this.width,
    this.height,
    this.hasShadow = false,
    this.border,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      padding: padding ?? const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: color ?? Colors.white,
        borderRadius: BorderRadius.circular(borderRadius),
        border: border,
        boxShadow: hasShadow
            ? [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
      ),
      child: child,
    );
  }
}
