import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AlertBanner extends StatelessWidget {
  const AlertBanner({
    Key? key,
    required this.icon,
    required this.color,
    required this.message,
  }) : super(key: key);

  final IconData icon;
  final Color color;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 18.r),
          SizedBox(width: 10.w),
          Expanded(
            child: Text(
              message,
              style: TextStyle(color: color, fontSize: 13.sp, height: 1.45),
            ),
          ),
        ],
      ),
    );
  }
}
