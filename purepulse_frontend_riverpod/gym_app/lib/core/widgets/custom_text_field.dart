// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import '../constants/app_constants.dart';
import '../theme/app_colors.dart';

class CustomTextField extends StatefulWidget {
  final String? label;
  final String hintText;
  final bool isPassword;
  final Widget? suffixIcon;
  final Widget? prefixIcon;
  final TextEditingController? controller;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;

  const CustomTextField({
    super.key,
    this.label,
    required this.hintText,
    this.isPassword = false,
    this.suffixIcon,
    this.prefixIcon,
    this.controller,
    this.validator,
    this.keyboardType,
    this.textInputAction,
  });

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  late bool _obscureText;

  @override
  void initState() {
    super.initState();
    _obscureText = widget.isPassword;
  }

  @override
  Widget build(BuildContext context) {
    Widget? effectiveSuffixIcon = widget.suffixIcon;
    if (widget.isPassword) {
      effectiveSuffixIcon = IconButton(
        icon: Icon(
          _obscureText ? Icons.visibility_off : Icons.visibility,
          color: AppColors.textSecondary,
        ),
        onPressed: () {
          setState(() {
            _obscureText = !_obscureText;
          });
        },
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.label != null) ...[
          Text(
            widget.label!,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
        ],
        TextFormField(
          controller: widget.controller,
          obscureText: _obscureText,
          validator: widget.validator,
          keyboardType: widget.keyboardType,
          textInputAction: widget.textInputAction,
          decoration: InputDecoration(
            hintText: widget.hintText,
            hintStyle: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 14,
            ),
            filled: true,
            fillColor: AppColors.inputBackground,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppConstants.textFieldBorderRadius),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppConstants.textFieldBorderRadius),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppConstants.textFieldBorderRadius),
              borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppConstants.textFieldBorderRadius),
              borderSide: const BorderSide(color: Colors.red, width: 1.0),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppConstants.textFieldBorderRadius),
              borderSide: const BorderSide(color: Colors.red, width: 1.5),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 24.0,
              vertical: 20.0,
            ),
            prefixIcon: widget.prefixIcon,
            prefixIconConstraints: const BoxConstraints(minWidth: 48, minHeight: 48),
            suffixIcon: effectiveSuffixIcon,
            suffixIconConstraints: const BoxConstraints(minWidth: 48, minHeight: 48),
          ),
        ),
      ],
    );
  }
}
