import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import '../../../core/models/attendance_model.dart';
import '../../../core/models/subject_model.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/services/firestore_service.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/text_styles.dart';
import '../../../core/widgets/faculty_info_dialog.dart';

class AttendanceHistoryScreen extends StatefulWidget {
  const AttendanceHistoryScreen({super.key});

  @override
  State<AttendanceHistoryScreen> createState() =>
      _AttendanceHistoryScreenState();
}

class _AttendanceHistoryScreenState extends State<AttendanceHistoryScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  final AuthService _authService = AuthService();
  List<AttendanceRecordModel> _records = [];
  List<AttendanceRecordModel> _filteredRecords = [];
  bool _isLoading = true;
  SubjectModel? _filterSubject;
  String _searchQuery = '';

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)!.settings.arguments;
    if (args is SubjectModel) {
      _filterSubject = args;
    }
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    final user = await _authService.getCurrentUserModel();

    List<AttendanceRecordModel> records;
    if (_filterSubject != null) {
      // Doctor viewing subject history
      records = await _firestoreService.getSubjectHistory(_filterSubject!.id);
    } else if (user != null && user.role == 'student') {
      // Student viewing their own history
      log(
        'Loading attendance history for student ID: ${user.studentId ?? user.id}',
      );
      records = await _firestoreService.getStudentHistory(
        user.studentId ?? user.id,
      );
    } else {
      // Admin or fallback
      records = await _firestoreService.getAllAttendance();
    }

    setState(() {
      _records = records;
      _filteredRecords = records;
      _isLoading = false;
    });
  }

  void _filterSearch(String query) {
    setState(() {
      _searchQuery = query;
      _filteredRecords = _records.where((record) {
        final name = record.studentName.toLowerCase();
        final subject = record.subjectName.toLowerCase();
        final search = query.toLowerCase();
        return name.contains(search) || subject.contains(search);
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _filterSubject != null
              ? 'حضور ${_filterSubject!.name}'
              : 'سجل الحضور',
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () => showFacultyInfo(context),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(15.w),
            child: TextField(
              onChanged: _filterSearch,
              decoration: InputDecoration(
                hintText: 'بحث باسم الطالب أو المادة...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15.r),
                ),
              ),
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredRecords.isEmpty
                ? const Center(child: Text('لا توجد سجلات مطابقة'))
                : ListView.builder(
                    padding: EdgeInsets.symmetric(horizontal: 20.w),
                    itemCount: _filteredRecords.length,
                    itemBuilder: (context, index) {
                      final record = _filteredRecords[index];
                      return _buildHistoryCard(record);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryCard(AttendanceRecordModel record) {
    final date = DateFormat('yyyy/MM/dd').format(record.timestamp);
    final time = DateFormat('hh:mm a').format(record.timestamp);

    return Card(
      margin: EdgeInsets.only(bottom: 12.h),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.r)),
      child: ListTile(
        title: Text(
          record.studentName,
          style: TextStyles.font20White500Weight(
            context,
          ).copyWith(color: ColorsManager.black, fontSize: 18.sp),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('المادة: ${record.subjectName}'),
            Text(
              'التاريخ: $date | الوقت: $time',
              style: TextStyle(fontSize: 12.sp, color: ColorsManager.grey),
            ),
          ],
        ),
        trailing: const Icon(Icons.check_circle, color: ColorsManager.green),
      ),
    );
  }
}
