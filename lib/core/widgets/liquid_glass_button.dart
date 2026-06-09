import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../theme/colors.dart';
import '../theme/text_styles.dart';

class LiquidGlassButton extends StatelessWidget {
  final String title;
  final String imagePath;
  final VoidCallback onTap;

  const LiquidGlassButton({
    super.key,
    required this.title,
    required this.imagePath,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 40.w, vertical: 10.h),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(30.r),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
          child: InkWell(
            borderRadius: BorderRadius.circular(30.r),
            onTap: onTap,
            child: Container(
              height: 80.h,
              padding: EdgeInsets.symmetric(horizontal: 18.w),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(50.r),
                color: const Color(0xFF0C6C78).withOpacity(0.75),
                border: Border.all(
                  color: ColorsManager.white.withOpacity(0.15),
                  width: 1.2,
                ),
              ),
              child: Row(
                children: [
                  SizedBox(
                    width: 52.w,
                    height: 52.h,

                    child: Image.asset(
                      imagePath,
                      width: 30.w,
                      height: 30.h,
                      fit: BoxFit.contain,
                    ),
                  ),
                  SizedBox(width: 16.w),
                  Expanded(
                    child: Text(
                      title,
                      style: TextStyles.font24Yellow700Weight(
                        context,
                      ).copyWith(fontSize: 30.sp),
                    ),
                  ),
                  const Icon(
                    Icons.arrow_forward,
                    color: ColorsManager.white,
                    size: 35,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
