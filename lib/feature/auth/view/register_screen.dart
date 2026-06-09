import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:smart_attendance/core/widgets/auth_container.dart';
import 'package:smart_attendance/core/widgets/auth_header.dart';
import '../../../core/theme/text_styles.dart';
import '../../../core/utils/app_assets.dart';
import '../../../core/widgets/auth_action_button.dart';
import '../../../core/widgets/auth_text_field.dart';
import '../view_model/register_view_model.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final RegisterViewModel _viewModel = RegisterViewModel();

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        constraints: BoxConstraints(
          minHeight: MediaQuery.of(context).size.height,
        ),
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage(AppAssets.authBg),
            fit: BoxFit.cover,
          ),
        ),
        child: SingleChildScrollView(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom + 10,
          ),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: MediaQuery.of(context).size.height - 100,
            ),
            child: IntrinsicHeight(
              child: Column(
                children: [
                  AuthHeader(
                    title: 'إنشاء حساب جديد',
                    onBack: () => Navigator.pop(context),
                  ),
                  Transform.translate(
                    offset: Offset(0, -110.h),
                    child: AuthContainer(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          AuthTextField(
                            controller: _viewModel.fullNameController,
                            hintText: 'أدخل الاسم بالكامل',
                            iconPath: AppAssets.profile,
                          ),
                          AuthTextField(
                            controller: _viewModel.facultyIdController,
                            hintText: 'أدخل ID الطالب',
                            iconPath: AppAssets
                                .idCard, // Assuming idCard exists or I'll check
                          ),
                          AuthTextField(
                            controller: _viewModel.emailController,
                            hintText: 'أدخل البريد الإلكتروني',
                            iconPath: AppAssets.email,
                          ),
                          AuthTextField(
                            controller: _viewModel.passwordController,
                            hintText: 'أدخل كلمة المرور',
                            iconPath: AppAssets.lock,
                            obscureText: true,
                          ),
                          AuthTextField(
                            controller: _viewModel.confirmPasswordController,
                            hintText: 'تأكيد كلمة المرور',
                            iconPath: AppAssets.lock,
                            obscureText: true,
                          ),
                          // SizedBox(height: 10.h),
                          ValueListenableBuilder<bool>(
                            valueListenable: _viewModel.isLoading,
                            builder: (context, isLoading, child) {
                              return AuthActionButton(
                                title: 'إنشاء الحساب',
                                isLoading: isLoading,
                                onPressed: () => _viewModel.register(context),
                              );
                            },
                          ),
                          SizedBox(height: 24.h),
                          GestureDetector(
                            onTap: () => _viewModel.goBack(context),
                            child: RichText(
                              text: TextSpan(
                                children: [
                                  TextSpan(
                                    text: "لديك حساب بالفعل؟ ",
                                    style: TextStyles.font24Yellow700Weight(
                                      context,
                                    ).copyWith(fontSize: 16.sp),
                                  ),
                                  TextSpan(
                                    text: "تسجيل الدخول",
                                    style:
                                        TextStyles.font20White500Weight(
                                          context,
                                        ).copyWith(
                                          fontSize: 16.sp,
                                          fontWeight: FontWeight.w700,
                                        ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 10.h),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
