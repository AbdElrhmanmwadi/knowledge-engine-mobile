import 'package:flutter/material.dart';

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
    Key? key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    this.isEnabled = true,
    this.style,
    this.icon,
    this.isOutlined = false,
    this.width,
    this.height = 48,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final button = isOutlined
        ? OutlinedButton(
            onPressed: isEnabled && !isLoading ? onPressed : null,
            style: style,
            child: _buildContent(),
          )
        : ElevatedButton(
            onPressed: isEnabled && !isLoading ? onPressed : null,
            style: style,
            child: _buildContent(),
          );

    if (width != null || height != null) {
      return SizedBox(
        width: width,
        height: height,
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
          const SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(
              strokeWidth: 2,
            ),
          ),
          const SizedBox(width: 8),
          Text(label),
        ],
      );
    }

    if (icon != null) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon),
          const SizedBox(width: 8),
          Text(label),
        ],
      );
    }

    return Text(label);
  }
}
