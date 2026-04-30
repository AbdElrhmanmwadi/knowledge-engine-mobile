import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Status badge widget for displaying status information
class StatusBadge extends StatelessWidget {
  final String status;
  final String label;
  final Color? backgroundColor;
  final Color? textColor;
  final IconData? icon;
  final double fontSize;
  final EdgeInsetsGeometry padding;

  const StatusBadge({
    Key? key,
    required this.status,
    required this.label,
    this.backgroundColor,
    this.textColor,
    this.icon,
    this.fontSize = 14,
    this.padding = const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
  }) : super(key: key);

  Color get _backgroundColor =>
      backgroundColor ?? AppTheme.getStatusColor(status);

  Color get _textColor => textColor ?? Colors.white;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: _backgroundColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(
              icon,
              size: fontSize,
              color: _textColor,
            ),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: TextStyle(
              color: _textColor,
              fontSize: fontSize,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
