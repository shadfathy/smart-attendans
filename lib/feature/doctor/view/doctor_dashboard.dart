import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/models/subject_model.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/services/firestore_service.dart';
import '../../../core/theme/colors.dart';
import '../../../core/widgets/faculty_info_dialog.dart';
import '../../admin/view/management/student_management_screen.dart';

class DoctorDashboard extends StatefulWidget {
  const DoctorDashboard({super.key});

  @override
  State<DoctorDashboard> createState() => _DoctorDashboardState();
}

class _DoctorDashboardState extends State<DoctorDashboard> {
  final FirestoreService _firestoreService = FirestoreService();
  final AuthService _authService = AuthService();
  List<SubjectModel> _subjects = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSubjects();
  }

  Future<void> _loadSubjects() async {
    try {
      final user = await _authService.getCurrentUserModel();
      if (user != null) {
        final subjects = await _firestoreService.getDoctorSubjects(user.id);
        if (mounted) {
          setState(() {
            _subjects = subjects;
            _isLoading = false;
          });
        }
      } else {
        if (mounted) setState(() => _isLoading = false);
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'لوحة تحكم الدكتور',
          style: TextStyle(color: ColorsManager.white, fontSize: 20.sp),
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
              await _authService.signOut();
              Navigator.pushReplacementNamed(context, AppRoutes.login);
            },
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(color: ColorsManager.grey100),
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _subjects.isEmpty
            ? const Center(child: Text('لا توجد مواد مسندة إليك حالياً'))
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.fromLTRB(25.w, 25.h, 25.w, 10.h),
                    child: Text(
                      'موادي الدراسية',
                      style: TextStyle(
                        fontSize: 22.sp,
                        fontWeight: FontWeight.bold,
                        color: ColorsManager.primaryColor,
                      ),
                    ),
                  ),
                  Expanded(
                    child: ListView.builder(
                      padding: EdgeInsets.symmetric(
                        horizontal: 20.w,
                        vertical: 10.h,
                      ),
                      itemCount: _subjects.length,
                      itemBuilder: (context, index) {
                        final subject = _subjects[index];
                        return _buildPremiumSubjectCard(subject);
                      },
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildPremiumSubjectCard(SubjectModel subject) {
    return Container(
      margin: EdgeInsets.only(bottom: 20.h),
      decoration: BoxDecoration(
        color: ColorsManager.white,
        borderRadius: BorderRadius.circular(25.r),
        boxShadow: [
          BoxShadow(
            color: ColorsManager.black.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(20.w),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(12.w),
                  decoration: BoxDecoration(
                    color: ColorsManager.blue.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.book,
                    color: ColorsManager.blue,
                    size: 28.w,
                  ),
                ),
                SizedBox(width: 15.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        subject.name,
                        style: TextStyle(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.bold,
                          color: ColorsManager.black,
                        ),
                      ),
                      Text(
                        'اختر إجراء للمادة:',
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: ColorsManager.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Divider(height: 1, color: ColorsManager.grey100),
          Padding(
            padding: EdgeInsets.all(10.w),
            child: Row(
              children: [
                Expanded(
                  child: _buildActionButton(
                    label: 'توليد QR',
                    icon: Icons.qr_code,
                    color: ColorsManager.blue,
                    onTap: () => Navigator.pushNamed(
                      context,
                      AppRoutes.generateQr,
                      arguments: subject,
                    ),
                  ),
                ),
                SizedBox(width: 10.w),
                Expanded(
                  child: _buildActionButton(
                    label: 'السجل',
                    icon: Icons.history,
                    color: ColorsManager.green,
                    onTap: () => Navigator.pushNamed(
                      context,
                      AppRoutes.attendanceHistory,
                      arguments: subject,
                    ),
                  ),
                ),
                SizedBox(width: 10.w),
                Expanded(
                  child: _buildActionButton(
                    label: 'تحضير يدوي',
                    icon: Icons.person_add,
                    color: ColorsManager.orange,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => StudentManagementScreen(
                            isDoctor: true,
                            currentSubject: subject,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 4.w),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(15.r),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 20.sp),
            SizedBox(width: 4.w),
            Text(
              label,
              style: TextStyle(color: color, fontSize: 12.sp),
            ),
          ],
        ),
      ),
    );
  }
}
