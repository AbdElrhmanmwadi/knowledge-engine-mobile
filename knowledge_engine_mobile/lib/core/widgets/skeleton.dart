import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// A softly pulsing placeholder block used to compose loading skeletons.
///
/// Dependency-free shimmer: it animates the fill opacity so lists can show
/// their shape while data loads, which reads faster than a bare spinner.
class SkeletonBox extends StatefulWidget {
  const SkeletonBox({
    super.key,
    this.width,
    this.height = 16,
    this.borderRadius = 8,
  });

  final double? width;
  final double height;
  final double borderRadius;

  @override
  State<SkeletonBox> createState() => _SkeletonBoxState();
}

class _SkeletonBoxState extends State<SkeletonBox>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1100),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final base = Theme.of(context).colorScheme.onSurface;
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) => Container(
        width: widget.width?.w,
        height: widget.height.h,
        decoration: BoxDecoration(
          color: base.withValues(alpha: 0.05 + 0.09 * _controller.value),
          borderRadius: BorderRadius.circular(widget.borderRadius.r),
        ),
      ),
    );
  }
}
