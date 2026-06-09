import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/services/firestore_service.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/text_styles.dart';
import '../../../core/widgets/faculty_info_dialog.dart';

class StudentDashboard extends StatefulWidget {
  const StudentDashboard({super.key});

  @override
  State<StudentDashboard> createState() => _StudentDashboardState();
}

class _StudentDashboardState extends State<StudentDashboard> {
  final FirestoreService _firestoreService = FirestoreService();
  final AuthService _authService = AuthService();

  int _unreadCount = 0;
  String? _studentId;

  @override
  void initState() {
    super.initState();
    _loadNotificationCount();
  }

  Future<void> _loadNotificationCount() async {
    final user = _authService.currentUser;
    if (user != null) {
      final userModel = await _firestoreService.getUser(user.uid);
      if (userModel != null && userModel.studentId != null) {
        if (mounted) {
          setState(() {
            _studentId = userModel.studentId;
          });
        }
        final count = await _firestoreService.getUnreadNotificationCount(
          userModel.studentId!,
        );
        if (mounted) {
          setState(() {
            _unreadCount = count;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'لوحة تحكم الطالب',
          style: TextStyle(color: ColorsManager.white, fontSize: 20.sp),
        ),
        centerTitle: false,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [ColorsManager.primaryColor, ColorsManager.primary400],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        actions: [
          Stack(
            alignment: Alignment.center,
            children: [
              IconButton(
                color: ColorsManager.white,
                icon: const Icon(Icons.notifications_none),
                onPressed: () {
                  if (_studentId != null) {
                    Navigator.pushNamed(
                      context,
                      AppRoutes.studentNotifications,
                      arguments: _studentId,
                    ).then((_) => _loadNotificationCount());
                  }
                },
              ),
              if (_unreadCount > 0)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: ColorsManager.red,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 16,
                      minHeight: 16,
                    ),
                    child: Text(
                      '$_unreadCount',
                      style: const TextStyle(
                        color: ColorsManager.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
          IconButton(
            color: ColorsManager.white,
            icon: const Icon(Icons.info_outline),
            onPressed: () => showFacultyInfo(context),
          ),
          IconButton(
            color: ColorsManager.white,
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await AuthService().signOut();
              Navigator.pushReplacementNamed(context, AppRoutes.login);
            },
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(color: ColorsManager.grey100),
        child: Padding(
          padding: EdgeInsets.all(25.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'أهلاً بك يا بطل!',
                style: TextStyle(
                  fontSize: 24.sp,
                  fontWeight: FontWeight.bold,
                  color: ColorsManager.primaryColor,
                ),
              ),
              // SizedBox(height: 5.h),
              Text(
                'جاهز لتسجيل حضورك اليوم؟',
                style: TextStyle(
                  fontSize: 14.sp,
                  color: ColorsManager.darkGray,
                ),
              ),
              SizedBox(height: 20.h),
              _buildPremiumOptionCard(
                context,
                title: 'مسح رمز QR',
                subtitle: 'قم بمسح الرمز لتسجيل حضورك فوراً',
                icon: Icons.qr_code_scanner,
                color: ColorsManager.indigo,
                onTap: () => Navigator.pushNamed(context, AppRoutes.scanQr),
              ),
              SizedBox(height: 20.h),
              _buildPremiumOptionCard(
                context,
                title: 'سجل الحضور',
                subtitle: 'راجع تاريخ حضورك في المحاضرات السابقة',
                icon: Icons.history,
                color: ColorsManager.green,
                onTap: () =>
                    Navigator.pushNamed(context, AppRoutes.attendanceHistory),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPremiumOptionCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(25.w),
        decoration: BoxDecoration(
          color: ColorsManager.white,
          borderRadius: BorderRadius.circular(30.r),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(15.w),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 35.w),
            ),
            SizedBox(width: 20.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: TextStyles.fontSize(18),
                      fontWeight: FontWeight.bold,
                      color: ColorsManager.black,
                    ),
                  ),
                  SizedBox(height: 5.h),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: TextStyles.fontSize(12),
                      color: ColorsManager.darkGray,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: ColorsManager.grey200,
              size: 18.w,
            ),
          ],
        ),
      ),
    );
  }
}
