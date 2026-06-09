import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:smart_attendance/feature/auth/view/login_screen.dart';
import 'package:smart_attendance/feature/auth/view/register_screen.dart';
import 'package:smart_attendance/firebase_options.dart';
import 'feature/splash/view/splash_screen.dart';
import 'core/routes/app_routes.dart';
import 'package:smart_attendance/feature/admin/view/admin_dashboard.dart';
import 'package:smart_attendance/feature/doctor/view/doctor_dashboard.dart';
import 'package:smart_attendance/feature/doctor/view/generate_qr_screen.dart';
import 'package:smart_attendance/feature/home/view/attendance_history_screen.dart';
import 'package:smart_attendance/feature/student/view/scan_qr_screen.dart';
import 'package:smart_attendance/feature/student/view/student_dashboard.dart';
import 'package:smart_attendance/feature/admin/view/management/student_management_screen.dart';
import 'package:smart_attendance/feature/admin/view/management/subject_management_screen.dart';
import 'package:smart_attendance/core/theme/colors.dart';
import 'package:smart_attendance/feature/admin/view/management/doctor_management_screen.dart';
import 'package:smart_attendance/feature/student/view/student_notifications_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (_, child) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: MaterialApp(
            title: 'Smart Attendance',
            debugShowCheckedModeBanner: false,
            initialRoute: AppRoutes.splash,
            locale: const Locale('ar'),
            supportedLocales: const [Locale('ar')],
            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            theme: ThemeData(
              fontFamily: 'Tajawal',
              primarySwatch: ColorsManager.primaryColor.toMaterialColor(),
              colorScheme: ColorScheme.fromSeed(
                seedColor: ColorsManager.primaryColor,
              ),
            ),
            routes: {
              AppRoutes.splash: (_) => const SplashScreen(),
              AppRoutes.login: (_) => const LoginScreen(),
              AppRoutes.register: (_) => const RegisterScreen(),
              AppRoutes.adminDashboard: (_) => const AdminDashboard(),
              AppRoutes.doctorDashboard: (_) => const DoctorDashboard(),
              AppRoutes.studentDashboard: (_) => const StudentDashboard(),
              AppRoutes.generateQr: (_) => const GenerateQrScreen(),
              AppRoutes.scanQr: (_) => const ScanQrScreen(),
              AppRoutes.attendanceHistory: (_) =>
                  const AttendanceHistoryScreen(),
              AppRoutes.studentList: (_) => const StudentManagementScreen(),
              AppRoutes.subjectList: (_) => const SubjectManagementScreen(),
              AppRoutes.doctorList: (_) => const DoctorManagementScreen(),
              AppRoutes.addStudent: (_) => const AddStudentScreen(),
              AppRoutes.addSubject: (_) => const AddSubjectScreen(),
              AppRoutes.addDoctor: (_) => const AddDoctorScreen(),
              AppRoutes.studentNotifications: (context) {
                final studentId =
                    ModalRoute.of(context)!.settings.arguments as String;
                return StudentNotificationsScreen(studentId: studentId);
              },
            },
          ),
        );
      },
    );
  }
}
