import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:smart_attendance/core/theme/text_styles.dart';
import '../../../core/utils/app_assets.dart';
import '../theme/colors.dart';

class AuthHeader extends StatelessWidget {
  final String title;
  final VoidCallback? onBack;

  const AuthHeader({super.key, required this.title, this.onBack});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 360.h,
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 18.w),
          child: Column(
            children: [
              SizedBox(height: 30.h),
              Image.asset(
                AppAssets.splashLogo,
                width: 300.w,
                height: 100.h,
                fit: BoxFit.cover,
              ),
              SizedBox(height: 4.h),
              Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyles.font24White500Weight(context).copyWith(
                  color: ColorsManager.teal,
                  shadows: const [
                    Shadow(
                      color: ColorsManager.white,
                      offset: Offset(2, 2),
                      blurRadius: 0,
                    ),
                  ],
                  fontSize: TextStyles.fontSize(40),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
