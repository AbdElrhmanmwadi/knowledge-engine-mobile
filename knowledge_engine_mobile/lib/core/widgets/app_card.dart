import 'package:flutter/material.dart';

/// Reusable app card widget
class AppCard extends StatelessWidget {
  final String? title;
  final Widget? child;
  final List<Widget>? children;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry margin;
  final double elevation;
  final Color? backgroundColor;
  final VoidCallback? onTap;
  final double borderRadius;

  const AppCard({
    Key? key,
    this.title,
    this.child,
    this.children,
    this.padding = const EdgeInsets.all(16),
    this.margin = const EdgeInsets.all(8),
    this.elevation = 2,
    this.backgroundColor,
    this.onTap,
    this.borderRadius = 8,
  })  : assert(child != null || children != null),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: margin,
      elevation: elevation,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      color: backgroundColor,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(borderRadius),
        child: Padding(
          padding: padding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (title != null) ...[
                Text(
                  title!,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 12),
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
