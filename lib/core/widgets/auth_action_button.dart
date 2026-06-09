import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../theme/colors.dart';
import '../theme/text_styles.dart';

class AuthActionButton extends StatelessWidget {
  final String title;
  final bool isLoading;
  final VoidCallback onPressed;

  const AuthActionButton({
    super.key,
    required this.title,
    this.isLoading = false,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(18.r)),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: ColorsManager.white,
            foregroundColor: ColorsManager.primary500,
            minimumSize: Size(260.w, 72.h),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18.r),
            ),
            elevation: 0,
          ),
          onPressed: isLoading ? null : onPressed,
          child: isLoading
              ? SizedBox(
                  height: 25.h,
                  width: 25.h,
                  child: const CircularProgressIndicator(
                    color: ColorsManager.primary500,
                    strokeWidth: 3,
                  ),
                )
              : Text(
                  title,
                  style: TextStyles.font24Primary500Weight(
                    context,
                  ).copyWith(fontSize: 20.sp, fontWeight: FontWeight.w700),
                ),
        ),
      ),
    );
  }
}
