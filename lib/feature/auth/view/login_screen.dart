import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:smart_attendance/core/widgets/auth_container.dart';
import 'package:smart_attendance/core/widgets/auth_header.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/text_styles.dart';
import '../../../core/utils/app_assets.dart';
import '../../../core/widgets/auth_action_button.dart';
import '../../../core/widgets/auth_text_field.dart';
import '../view_model/login_view_model.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final LoginViewModel _viewModel = LoginViewModel();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    // Listen for tab changes to update the UI
    _tabController.addListener(() {
      if (mounted) setState(() {});
    });
    // Initialize biometric authentication
    _viewModel.initBiometric();
  }

  @override
  void dispose() {
    _tabController.dispose();
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
            bottom: MediaQuery.of(context).viewInsets.bottom + 20,
          ),
          child: Column(
            children: [
              AuthHeader(
                title: 'تسجيل الدخول',
                onBack: () => Navigator.pop(context),
              ),
              Transform.translate(
                offset: Offset(0, -120.h),
                child: AuthContainer(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Premium Tab Selector
                      Container(
                        height: 60.h,
                        padding: EdgeInsets.all(5.w),
                        decoration: BoxDecoration(
                          color: ColorsManager.grey100,
                          borderRadius: BorderRadius.circular(20.r),
                          boxShadow: [
                            BoxShadow(
                              color: ColorsManager.black.withOpacity(0.05),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: TabBar(
                          controller: _tabController,
                          indicator: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                ColorsManager.primary500,
                                ColorsManager.primary400,
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(15.r),
                            boxShadow: [
                              BoxShadow(
                                color: ColorsManager.primary500.withOpacity(
                                  0.3,
                                ),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          labelColor: ColorsManager.white,
                          unselectedLabelColor: ColorsManager.darkGray,
                          labelStyle: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16.sp,
                          ),
                          indicatorSize: TabBarIndicatorSize.tab,
                          dividerColor: ColorsManager.transparent,
                          tabs: const [
                            Tab(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.supervisor_account_outlined,
                                    size: 20,
                                  ),
                                  SizedBox(width: 8),
                                  Text('دكتور'),
                                ],
                              ),
                            ),
                            Tab(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.school_outlined, size: 20),
                                  SizedBox(width: 8),
                                  Text('طالب'),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 35.h),

                      // Animated Content
                      AnimatedSize(
                        duration: const Duration(milliseconds: 300),
                        child: _tabController.index == 0
                            ? Column(
                                children: [
                                  AuthTextField(
                                    controller: _viewModel.emailController,
                                    hintText: 'البريد الإلكتروني',
                                    iconPath: AppAssets.email,
                                  ),
                                  AuthTextField(
                                    controller: _viewModel.passwordController,
                                    hintText: 'كلمة المرور',
                                    iconPath: AppAssets.lock,
                                    obscureText: true,
                                  ),
                                ],
                              )
                            : Column(
                                children: [
                                  // Biometric login section for returning students
                                  ValueListenableBuilder<bool>(
                                    valueListenable:
                                        _viewModel.hasStoredCredentials,
                                    builder: (context, hasCredentials, child) {
                                      if (!hasCredentials) {
                                        return Column(
                                          children: [
                                            // Manual login fields (always visible)
                                            AuthTextField(
                                              controller:
                                                  _viewModel.nameController,
                                              hintText: 'الاسم بالكامل',
                                              iconPath: AppAssets.profile,
                                            ),
                                            AuthTextField(
                                              controller:
                                                  _viewModel.idController,
                                              hintText: 'الرقم الجامعي',
                                              iconPath: AppAssets.idCard,
                                            ),
                                          ],
                                        );
                                      }
                                      return Column(
                                        children: [
                                          ValueListenableBuilder<bool>(
                                            valueListenable:
                                                _viewModel.isBiometricLoading,
                                            builder: (context, isBiometricLoading, child) {
                                              return GestureDetector(
                                                onTap: isBiometricLoading
                                                    ? null
                                                    : () => _viewModel
                                                          .loginWithBiometric(
                                                            context,
                                                          ),
                                                child: Container(
                                                  padding: EdgeInsets.symmetric(
                                                    vertical: 20.h,
                                                    horizontal: 24.w,
                                                  ),
                                                  decoration: BoxDecoration(
                                                    gradient: LinearGradient(
                                                      colors: [
                                                        ColorsManager.primary500
                                                            .withOpacity(0.1),
                                                        ColorsManager.primary400
                                                            .withOpacity(0.05),
                                                      ],
                                                      begin: Alignment.topLeft,
                                                      end:
                                                          Alignment.bottomRight,
                                                    ),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          16.r,
                                                        ),
                                                    border: Border.all(
                                                      color: ColorsManager
                                                          .primary500
                                                          .withOpacity(0.3),
                                                      width: 1.5,
                                                    ),
                                                  ),
                                                  child: Column(
                                                    children: [
                                                      Icon(
                                                        Icons.fingerprint,
                                                        size: 48.sp,
                                                        color:
                                                            ColorsManager.white,
                                                      ),
                                                      SizedBox(height: 12.h),
                                                      Text(
                                                        'الدخول بالبصمة',
                                                        style:
                                                            TextStyles.font20White500Weight(
                                                              context,
                                                            ).copyWith(
                                                              color:
                                                                  ColorsManager
                                                                      .white,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600,
                                                            ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              );
                                            },
                                          ),
                                        ],
                                      );
                                    },
                                  ),
                                ],
                              ),
                      ),

                      // SizedBox(height: 16.h),
                      ValueListenableBuilder<bool>(
                        valueListenable: _viewModel.isLoading,
                        builder: (context, isLoading, child) {
                          return AuthActionButton(
                            title: 'دخول',
                            isLoading: isLoading,
                            onPressed: () {
                              if (_tabController.index == 0) {
                                _viewModel.login(context);
                              } else {
                                _viewModel.loginAsStudent(context);
                              }
                            },
                          );
                        },
                      ),
                      SizedBox(height: 24.h),
                      GestureDetector(
                        onTap: () => _viewModel.goToRegister(context),
                        child: RichText(
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text: "ليس لديك حساب؟ ",
                                style: TextStyles.font24Yellow700Weight(
                                  context,
                                ).copyWith(fontSize: 16.sp),
                              ),
                              TextSpan(
                                text: "سجل الآن",
                                style: TextStyles.font20White500Weight(context)
                                    .copyWith(
                                      fontSize: 16.sp,
                                      fontWeight: FontWeight.w700,
                                    ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: 26.h),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 20.h),
            ],
          ),
        ),
      ),
    );
  }
}
