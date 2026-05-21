import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class OutputCard extends StatelessWidget {
  const OutputCard({
    Key? key,
    required this.label,
    required this.icon,
    required this.content,
    required this.accentColor,
    required this.card,
    required this.textSecondary,
  }) : super(key: key);

  final String label;
  final IconData icon;
  final String content;
  final Color accentColor;
  final Color card;
  final Color textSecondary;

  @override
  Widget build(BuildContext context) {
    final isEmpty = content.isEmpty;
    return Container(
      decoration: BoxDecoration(
        color: card,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(
          color: isEmpty
              ? Colors.white.withOpacity(0.07)
              : accentColor.withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: EdgeInsets.fromLTRB(16.w, 14.h, 16.w, 0.h),
            child: Row(
              children: [
                Icon(icon, color: accentColor, size: 16.r),
                SizedBox(width: 8.w),
                Text(
                  label,
                  style: TextStyle(
                    color: accentColor,
                    fontWeight: FontWeight.w700,
                    fontSize: 12.sp,
                    letterSpacing: 0.8,
                  ),
                ),
                if (!isEmpty) ...[
                  const Spacer(),
                  Text(
                    '${content.length} chars',
                    style: TextStyle(color: textSecondary, fontSize: 11.sp),
                  ),
                ],
              ],
            ),
          ),
          Divider(color: Colors.white.withOpacity(0.06), height: 20.h),
          Padding(
            padding: EdgeInsets.fromLTRB(16.w, 0.h, 16.w, 16.h),
            child: SelectableText(
              isEmpty ? 'No output yet…' : content,
              style: TextStyle(
                color: isEmpty
                    ? textSecondary.withOpacity(0.5)
                    : const Color(0xFFF0F2FF),
                fontSize: 14.sp,
                height: 1.6,
                fontStyle: isEmpty ? FontStyle.italic : FontStyle.normal,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
