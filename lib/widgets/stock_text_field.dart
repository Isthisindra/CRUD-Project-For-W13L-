// lib/widgets/stock_text_field.dart
// Widget input field custom untuk desain Stock+.

import 'package:flutter/cupertino.dart';
import '../utils/app_theme.dart';

class StockTextField extends StatelessWidget {
  final TextEditingController controller;
  final String placeholder;
  final bool obscureText;
  final int maxLines;
  final TextCapitalization textCapitalization;
  final TextInputType? keyboardType;
  final ValueChanged<String>? onSubmitted;

  const StockTextField({
    super.key,
    required this.controller,
    required this.placeholder,
    this.obscureText = false,
    this.maxLines = 1,
    this.textCapitalization = TextCapitalization.none,
    this.keyboardType,
    this.onSubmitted,
  });

  @override
  Widget build(BuildContext context) {
    return CupertinoTextField(
      controller: controller,
      placeholder: placeholder,
      obscureText: obscureText,
      maxLines: maxLines,
      textCapitalization: textCapitalization,
      keyboardType: keyboardType,
      onSubmitted: onSubmitted,
      padding: const EdgeInsets.symmetric(
        horizontal: AppTheme.spacingLG,
        vertical: AppTheme.spacingMD + 2,
      ),
      placeholderStyle: const TextStyle(
        color: AppTheme.textTertiary,
        fontSize: AppTheme.fontMD,
      ),
      style: const TextStyle(
        color: AppTheme.textPrimary,
        fontSize: AppTheme.fontMD,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(AppTheme.radiusMD),
      ),
    );
  }
}
