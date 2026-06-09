import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/theme/colors.dart';
import '../../../core/widgets/faculty_info_dialog.dart';

class AdminDashboard extends StatelessWidget {
  const AdminDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final AuthService authService = AuthService();

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'لوحة تحكم المسؤول',
          style: TextStyle(color: ColorsManager.white),
        ),
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
          IconButton(
            color: ColorsManager.white,
            icon: const Icon(Icons.info_outline),
            onPressed: () => showFacultyInfo(context),
          ),
          IconButton(
            color: ColorsManager.white,
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await authService.signOut();
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
                'مرحباً بك، المسؤول',
                style: TextStyle(
                  fontSize: 24.sp,
                  fontWeight: FontWeight.bold,
                  color: ColorsManager.teal,
                ),
              ),
              SizedBox(height: 10.h),
              Text(
                'اختر القسم الذي ترغب في إدارته من القائمة أدناه:',
                style: TextStyle(
                  fontSize: 14.sp,
                  color: ColorsManager.darkGray,
                ),
              ),
              SizedBox(height: 30.h),
              Expanded(
                child: GridView.count(
                  crossAxisCount: 1,
                  childAspectRatio: 2.8,
                  mainAxisSpacing: 20.h,
                  children: [
                    _buildManagementCard(
                      context,
                      title: 'إدارة الطلاب',
                      subtitle: 'إضافة، عرض، وحذف الطلاب من الدليل',
                      icon: Icons.people,
                      color: ColorsManager.teal,
                      onTap: () =>
                          Navigator.pushNamed(context, AppRoutes.studentList),
                    ),
                    _buildManagementCard(
                      context,
                      title: 'إدارة المواد',
                      subtitle: 'إدارة المواد الدراسية وحالة تفعيلها',
                      icon: Icons.library_books,
                      color: ColorsManager.teal,
                      onTap: () =>
                          Navigator.pushNamed(context, AppRoutes.subjectList),
                    ),
                    _buildManagementCard(
                      context,
                      title: 'إدارة الدكاترة',
                      subtitle: 'إضافة وإدارة حسابات أعضاء هيئة التدريس',
                      icon: Icons.supervisor_account,
                      color: ColorsManager.teal,
                      onTap: () =>
                          Navigator.pushNamed(context, AppRoutes.doctorList),
                    ),
                    _buildManagementCard(
                      context,
                      title: 'سجل الحضور العام',
                      subtitle: 'مراجعة كافة سجلات الحضور في التطبيق',
                      icon: Icons.list_alt,
                      color: ColorsManager.teal,
                      onTap: () => Navigator.pushNamed(
                        context,
                        AppRoutes.attendanceHistory,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildManagementCard(
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
        padding: EdgeInsets.all(20.w),
        decoration: BoxDecoration(
          color: ColorsManager.white,
          borderRadius: BorderRadius.circular(25.r),
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
              child: Icon(icon, color: color, size: 30.w),
            ),
            SizedBox(width: 20.w),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                      color: ColorsManager.black,
                    ),
                  ),
                  SizedBox(height: 5.h),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12.sp,
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
