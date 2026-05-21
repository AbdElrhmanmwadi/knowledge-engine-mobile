import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Reusable app card widget
class AppCard extends StatelessWidget {
  final String? title;
  final Widget? child;
  final List<Widget>? children;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double elevation;
  final Color? backgroundColor;
  final VoidCallback? onTap;
  final double borderRadius;

  const AppCard({
    Key? key,
    this.title,
    this.child,
    this.children,
    this.padding,
    this.margin,
    this.elevation = 2,
    this.backgroundColor,
    this.onTap,
    this.borderRadius = 8,
  })  : assert(child != null || children != null),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: margin ?? EdgeInsets.all(8.r),
      elevation: elevation,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(borderRadius.r),
      ),
      color: backgroundColor,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(borderRadius.r),
        child: Padding(
          padding: padding ?? EdgeInsets.all(16.r),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (title != null) ...[
                Text(
                  title!,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                SizedBox(height: 12.h),
              ],
              if (child != null)
                child!
              else
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: children!,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
