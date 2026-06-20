import 'package:flutter/material.dart';

/// An [Icon] that mirrors horizontally when the ambient text direction is RTL.
///
/// Use for directional glyphs (arrows, chevrons) so they point the correct
/// way in right-to-left locales such as Arabic. Non-directional icons should
/// keep using the regular [Icon] widget.
class DirectionalIcon extends StatelessWidget {
  const DirectionalIcon(
    this.icon, {
    super.key,
    this.size,
    this.color,
  });

  final IconData icon;
  final double? size;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final icon = Icon(this.icon, size: size, color: color);
    final isRtl = Directionality.of(context) == TextDirection.rtl;
    if (!isRtl) return icon;
    return Transform.flip(flipX: true, child: icon);
  }
}
