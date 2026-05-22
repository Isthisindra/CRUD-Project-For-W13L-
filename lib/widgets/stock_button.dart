// lib/widgets/stock_button.dart
// Widget tombol kustom untuk desain Stock+.

import 'package:flutter/cupertino.dart';
import '../utils/app_theme.dart';

enum StockButtonStyle { filled, outlined, danger }

class StockButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final StockButtonStyle style;
  final bool isLoading;
  final IconData? icon;

  const StockButton({
    super.key,
    required this.label,
    this.onPressed,
    this.style = StockButtonStyle.filled,
    this.isLoading = false,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: GestureDetector(
        onTap: isLoading ? null : onPressed,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: AppTheme.spacingMD + 2),
          decoration: BoxDecoration(
            color: _backgroundColor,
            borderRadius: BorderRadius.circular(AppTheme.radiusMD),
            border: style == StockButtonStyle.outlined
                ? Border.all(color: AppTheme.primaryBlue, width: 1.5)
                : style == StockButtonStyle.danger
                    ? Border.all(color: AppTheme.danger, width: 1.5)
                    : null,
            boxShadow: style == StockButtonStyle.filled && onPressed != null
                ? [
                    BoxShadow(
                      color: AppTheme.primaryBlue.withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ]
                : null,
          ),
          child: Center(
            child: isLoading
                ? CupertinoActivityIndicator(
                    color: style == StockButtonStyle.filled
                        ? AppTheme.white
                        : (style == StockButtonStyle.danger
                            ? AppTheme.danger
                            : AppTheme.primaryBlue),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (icon != null) ...[
                        Icon(icon, size: 18, color: _textColor),
                        const SizedBox(width: AppTheme.spacingSM),
                      ],
                      Text(
                        label,
                        style: TextStyle(
                          fontSize: AppTheme.fontMD,
                          fontWeight: FontWeight.w600,
                          color: _textColor,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }

  Color get _backgroundColor {
    switch (style) {
      case StockButtonStyle.filled:
        return onPressed != null ? AppTheme.primaryBlue : AppTheme.textTertiary;
      case StockButtonStyle.outlined:
      case StockButtonStyle.danger:
        return AppTheme.white;
    }
  }

  Color get _textColor {
    switch (style) {
      case StockButtonStyle.filled:
        return AppTheme.white;
      case StockButtonStyle.outlined:
        return AppTheme.primaryBlue;
      case StockButtonStyle.danger:
        return AppTheme.danger;
    }
  }
}
