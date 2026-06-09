import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../theme/colors.dart';
import '../theme/text_styles.dart';

class AuthTextField extends StatefulWidget {
  final TextEditingController controller;
  final String hintText;
  final String iconPath;
  final bool obscureText;

  const AuthTextField({
    super.key,
    required this.controller,
    required this.hintText,
    required this.iconPath,
    this.obscureText = false,
  });

  @override
  State<AuthTextField> createState() => _AuthTextFieldState();
}

class _AuthTextFieldState extends State<AuthTextField> {
  late bool _isObscured;

  @override
  void initState() {
    super.initState();
    _isObscured = widget.obscureText;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 62.h,
      margin: EdgeInsets.only(bottom: 24.h),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(32.r),
        gradient: LinearGradient(
          colors: [
            ColorsManager.white.withOpacity(0.18),
            ColorsManager.white.withOpacity(0.08),
          ],
        ),
        border: Border.all(color: ColorsManager.white.withOpacity(0.4), width: 1),
      ),
      child: TextFormField(
        controller: widget.controller,
        obscureText: _isObscured,
        style: TextStyles.font20White500Weight(
          context,
        ).copyWith(fontWeight: FontWeight.w600),
        decoration: InputDecoration(
          hintText: widget.hintText,
          hintStyle: TextStyles.font20White500Weight(context).copyWith(
            fontWeight: FontWeight.w600,
            color: ColorsManager.white.withOpacity(0.95),
          ),
          prefixIconConstraints: BoxConstraints(
            minWidth: 70.w,
            minHeight: 24.h,
          ),
          prefixIcon: Padding(
            padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 14.h),
            child: Image.asset(
              widget.iconPath,
              width: 26.w,
              height: 26.h,
              color: ColorsManager.white,
            ),
          ),
          suffixIcon: widget.obscureText
              ? IconButton(
                  icon: Icon(
                    _isObscured ? Icons.visibility_off : Icons.visibility,
                    color: ColorsManager.white.withOpacity(0.8),
                    size: 24.w,
                  ),
                  onPressed: () {
                    setState(() {
                      _isObscured = !_isObscured;
                    });
                  },
                )
              : null,
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(
            horizontal: 20.w,
            vertical: 18.h,
          ),
        ),
      ),
    );
  }
}
