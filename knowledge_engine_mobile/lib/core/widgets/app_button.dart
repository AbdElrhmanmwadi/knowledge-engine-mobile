import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Reusable app button widget with loading state
class AppButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  final bool isLoading;
  final bool isEnabled;
  final ButtonStyle? style;
  final IconData? icon;
  final bool isOutlined;
  final double? width;
  final double? height;

  const AppButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    this.isEnabled = true,
    this.style,
    this.icon,
    this.isOutlined = false,
    this.width,
    this.height = 48,
  });

  @override
  Widget build(BuildContext context) {
    void handlePressed() {
      HapticFeedback.lightImpact();
      onPressed();
    }

    final button = isOutlined
        ? OutlinedButton(
            onPressed: isEnabled && !isLoading ? handlePressed : null,
            style: style,
            child: _buildContent(),
          )
        : ElevatedButton(
            onPressed: isEnabled && !isLoading ? handlePressed : null,
            style: style,
            child: _buildContent(),
          );

    if (width != null || height != null) {
      return SizedBox(
        width: width?.w,
        height: height?.h,
        child: button,
      );
    }

    return button;
  }

  Widget _buildContent() {
    if (isLoading) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 16.w,
            height: 16.h,
            child: const CircularProgressIndicator(
              strokeWidth: 2,
            ),
          ),
          SizedBox(width: 8.w),
          Text(label),
        ],
      );
    }

    if (icon != null) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon),
          SizedBox(width: 8.w),
          Text(label),
        ],
      );
    }

    return Text(label);
  }
}
