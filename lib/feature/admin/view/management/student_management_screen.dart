import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/services/firestore_service.dart';
import '../../../../core/theme/colors.dart';
import '../../../../core/models/attendance_model.dart';
import '../../../../core/models/subject_model.dart';

class StudentManagementScreen extends StatefulWidget {
  final bool isDoctor;
  final SubjectModel? currentSubject;

  const StudentManagementScreen({
    super.key,
    this.isDoctor = false,
    this.currentSubject,
  });

  @override
  State<StudentManagementScreen> createState() =>
      _StudentManagementScreenState();
}

class _StudentManagementScreenState extends State<StudentManagementScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  List<Map<String, dynamic>> _allStudents = [];
  List<Map<String, dynamic>> _filteredStudents = [];
  bool _isLoading = true;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadStudents();
    _searchController.addListener(_filterStudents);
  }

  Future<void> _loadStudents() async {
    try {
      setState(() => _isLoading = true);
      final students = await _firestoreService.getAllStudentsFromDirectory();
      if (mounted) {
        setState(() {
          _allStudents = students;
          _filteredStudents = students;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _filterStudents() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredStudents = _allStudents.where((student) {
        final name = (student['Name'] ?? '').toString().toLowerCase();
        final id = (student['Student_ID'] ?? '').toString().toLowerCase();
        return name.contains(query) || id.contains(query);
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isDoctor ? 'اختيار طالب للتحضير' : 'إدارة الطلاب'),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: widget.isDoctor
                  ? [ColorsManager.primaryColor, ColorsManager.primary400]
                  : [ColorsManager.primaryColor, ColorsManager.primary400],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(15.w),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'ابحث بالاسم أو الرقم الجامعي...',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: ColorsManager.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15.r),
                  borderSide: BorderSide.none,
                ),
                contentPadding: EdgeInsets.symmetric(horizontal: 20.w),
              ),
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredStudents.isEmpty
                ? const Center(child: Text('لم يتم العثور على نتائج'))
                : ListView.builder(
                    padding: EdgeInsets.symmetric(horizontal: 20.w),
                    itemCount: _filteredStudents.length,
                    itemBuilder: (context, index) {
                      final student = _filteredStudents[index];
                      return _buildStudentCard(student);
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: !widget.isDoctor
          ? FloatingActionButton(
              onPressed: () => _showAddOrEditStudentPage(context),
              backgroundColor: ColorsManager.teal,
              child: const Icon(Icons.add, color: ColorsManager.white),
            )
          : null,
    );
  }

  Widget _buildStudentCard(Map<String, dynamic> student) {
    return Container(
      margin: EdgeInsets.only(bottom: 15.h),
      padding: EdgeInsets.all(15.w),
      decoration: BoxDecoration(
        color: ColorsManager.white,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: ColorsManager.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: (widget.isDoctor ? ColorsManager.blue : ColorsManager.teal)
                  .withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.person,
              color: widget.isDoctor ? ColorsManager.blue : ColorsManager.teal,
              size: 25.w,
            ),
          ),
          SizedBox(width: 15.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  student['Name'] ?? '',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16.sp,
                  ),
                ),
                Text(
                  'ID: ${student['Student_ID']} | ${student['Department']}',
                  style: TextStyle(color: ColorsManager.grey, fontSize: 12.sp),
                ),
              ],
            ),
          ),
          if (widget.isDoctor)
            IconButton(
              icon: const Icon(
                Icons.check_circle_outline,
                color: ColorsManager.green,
              ),
              onPressed: () => _manualAttendance(student),
            )
          else ...[
            IconButton(
              icon: const Icon(Icons.edit_outlined, color: ColorsManager.blue),
              onPressed: () =>
                  _showAddOrEditStudentPage(context, student: student),
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline, color: ColorsManager.red),
              onPressed: () => _confirmDelete(student['id']),
            ),
          ],
        ],
      ),
    );
  }

  void _manualAttendance(Map<String, dynamic> student) {
    if (widget.currentSubject == null) return;

    showDialog(
      context: context,
      builder: (context) {
        bool innerLoading = false;
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('تحضير يدوي'),
              content: innerLoading
                  ? const SizedBox(
                      height: 100,
                      child: Center(child: CircularProgressIndicator()),
                    )
                  : Text(
                      'هل تريد تحضير الطالب "${student['Name']}" في مادة ${widget.currentSubject!.name}؟',
                    ),
              actions: innerLoading
                  ? []
                  : [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('إلغاء'),
                      ),
                      ElevatedButton(
                        onPressed: () async {
                          setState(() => innerLoading = true);
                          final docRef = FirebaseFirestore.instance
                              .collection('attendance')
                              .doc();
                          final record = AttendanceRecordModel(
                            id: docRef.id,
                            studentId: student['Student_ID'].toString(),
                            studentName: student['Name'],
                            subjectId: widget.currentSubject!.id,
                            subjectName: widget.currentSubject!.name,
                            timestamp: DateTime.now(),
                          );
                          await _firestoreService.recordAttendance(record);
                          if (mounted) {
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('تم التحضير بنجاح')),
                            );
                          }
                        },
                        child: const Text('تأكيد'),
                      ),
                    ],
            );
          },
        );
      },
    );
  }

  void _confirmDelete(String id) {
    showDialog(
      context: context,
      builder: (context) {
        bool innerLoading = false;
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('تأكيد الحذف'),
              content: innerLoading
                  ? const SizedBox(
                      height: 100,
                      child: Center(child: CircularProgressIndicator()),
                    )
                  : const Text('هل أنت متأكد من حذف هذا الطالب من الدليل؟'),
              actions: innerLoading
                  ? []
                  : [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('إلغاء'),
                      ),
                      TextButton(
                        onPressed: () async {
                          setState(() => innerLoading = true);
                          await _firestoreService.deleteStudentFromDirectory(
                            id,
                          );
                          Navigator.pop(context);
                          _loadStudents();
                        },
                        child: const Text(
                          'حذف',
                          style: TextStyle(color: ColorsManager.red),
                        ),
                      ),
                    ],
            );
          },
        );
      },
    );
  }

  void _showAddOrEditStudentPage(
    BuildContext context, {
    Map<String, dynamic>? student,
  }) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddStudentScreen(student: student),
      ),
    ).then((_) => _loadStudents());
  }
}

class AddStudentScreen extends StatefulWidget {
  final Map<String, dynamic>? student;
  const AddStudentScreen({super.key, this.student});

  @override
  State<AddStudentScreen> createState() => _AddStudentScreenState();
}

class _AddStudentScreenState extends State<AddStudentScreen> {
  late TextEditingController nameController;
  late TextEditingController idController;
  late TextEditingController branchController;
  late TextEditingController deptController;
  late TextEditingController gradeController;
  final FirestoreService _firestoreService = FirestoreService();
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: widget.student?['Name'] ?? '');
    idController = TextEditingController(
      text: widget.student?['Student_ID']?.toString() ?? '',
    );
    branchController = TextEditingController(
      text: widget.student?['Branch'] ?? 'المنصورة',
    );
    deptController = TextEditingController(
      text: widget.student?['Department'] ?? 'تكنولوجيا التعليم',
    );
    gradeController = TextEditingController(
      text: widget.student?['Grade'] ?? 'الثالثة',
    );
  }

  @override
  Widget build(BuildContext context) {
    bool isEditing = widget.student != null;
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'تعديل بيانات الطالب' : 'إضافة طالب جديد'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(25.w),
        child: Column(
          children: [
            _buildTextField(nameController, 'الاسم بالكامل', Icons.person),
            _buildTextField(idController, 'رقم الطالب', Icons.badge),
            _buildTextField(branchController, 'الفرع', Icons.location_city),
            _buildTextField(deptController, 'القسم', Icons.category),
            _buildTextField(gradeController, 'الفرقة', Icons.school),
            SizedBox(height: 40.h),
            ElevatedButton(
              onPressed: _isSaving
                  ? null
                  : () async {
                      if (nameController.text.isNotEmpty &&
                          idController.text.isNotEmpty) {
                        setState(() => _isSaving = true);
                        try {
                          if (isEditing) {
                            await _firestoreService.updateStudentInDirectory(
                              widget.student!['id'],
                              nameController.text,
                              idController.text,
                              branchController.text,
                              deptController.text,
                              gradeController.text,
                            );
                          } else {
                            await _firestoreService.addStudentToDirectory(
                              nameController.text,
                              idController.text,
                              branchController.text,
                              deptController.text,
                              gradeController.text,
                            );
                          }
                          if (mounted) Navigator.pop(context);
                        } finally {
                          if (mounted) setState(() => _isSaving = false);
                        }
                      }
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: ColorsManager.teal,
                minimumSize: Size(double.infinity, 55.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15.r),
                ),
              ),
              child: _isSaving
                  ? const CircularProgressIndicator(color: ColorsManager.white)
                  : Text(
                      isEditing ? 'تحديث البيانات' : 'حفظ الطالب',
                      style: const TextStyle(
                        color: ColorsManager.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label,
    IconData icon,
  ) {
    return Padding(
      padding: EdgeInsets.only(bottom: 20.h),
      child: TextField(
        controller: controller,
        enabled: !_isSaving,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: ColorsManager.teal),
          filled: true,
          fillColor: ColorsManager.grey100,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15.r),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }
}
