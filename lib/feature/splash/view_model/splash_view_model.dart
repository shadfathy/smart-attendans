import 'dart:async';
import 'package:flutter/material.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/services/auth_service.dart';

class SplashViewModel {
  final AuthService _authService = AuthService();

  void navigateToNext(BuildContext context) {
    Timer(const Duration(seconds: 4), () async {
      if (context.mounted) {
        final user = await _authService.getCurrentUserModel();

        if (user == null) {
          Navigator.pushReplacementNamed(context, AppRoutes.login);
        } else {
          if (user.email == 'admin@smartattendance.com' ||
              user.role == 'admin') {
            Navigator.pushReplacementNamed(context, AppRoutes.adminDashboard);
          } else if (user.role == 'doctor' || user.isDoctor) {
            Navigator.pushReplacementNamed(context, AppRoutes.doctorDashboard);
          } else {
            Navigator.pushReplacementNamed(context, AppRoutes.studentDashboard);
          }
        }
      }
    });
  }
}
