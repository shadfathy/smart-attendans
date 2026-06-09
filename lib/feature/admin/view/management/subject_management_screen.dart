import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/services/firestore_service.dart';
import '../../../../core/theme/colors.dart';
import '../../../../core/models/subject_model.dart';

class SubjectManagementScreen extends StatefulWidget {
  const SubjectManagementScreen({super.key});

  @override
  State<SubjectManagementScreen> createState() =>
      _SubjectManagementScreenState();
}

class _SubjectManagementScreenState extends State<SubjectManagementScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  List<SubjectModel> _subjects = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSubjects();
  }

  Future<void> _loadSubjects() async {
    try {
      setState(() => _isLoading = true);
      final subjects = await _firestoreService.getAllSubjects();
      if (mounted) {
        setState(() {
          _subjects = subjects;
          _isLoading = false;
        });
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
          'إدارة المواد',
          style: TextStyle(fontSize: 22.sp, color: ColorsManager.white),
        ),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [ColorsManager.primaryColor, ColorsManager.primary400],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _subjects.isEmpty
          ? const Center(child: Text('لا توجد مواد مضافة'))
          : ListView.builder(
              padding: EdgeInsets.all(20.w),
              itemCount: _subjects.length,
              itemBuilder: (context, index) {
                final subject = _subjects[index];
                return _buildSubjectCard(subject);
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddSubjectPage(context),
        backgroundColor: ColorsManager.teal,
        child: const Icon(Icons.add, color: ColorsManager.white),
      ),
    );
  }

  Widget _buildSubjectCard(SubjectModel subject) {
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
              color: ColorsManager.teal.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.book, color: ColorsManager.teal, size: 25.w),
          ),
          SizedBox(width: 15.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  subject.name,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16.sp,
                  ),
                ),
                Text(
                  subject.doctorId == null ? 'غير نشطة (بدون دكتور)' : 'نشطة',
                  style: TextStyle(
                    color: subject.doctorId == null
                        ? ColorsManager.orange
                        : ColorsManager.green,
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(
              Icons.group_add_outlined,
              color: ColorsManager.primaryColor,
            ),
            tooltip: 'تخصيص الطلاب',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      EditSubjectStudentsScreen(subject: subject),
                ),
              ).then((_) => _loadSubjects());
            },
          ),
          IconButton(
            icon: const Icon(
              Icons.notifications_active_outlined,
              color: ColorsManager.orange,
            ),
            tooltip: 'إرسال تنبيه غياب',
            onPressed: () => _confirmSendAbsenceAlert(subject),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, color: ColorsManager.red),
            onPressed: () => _confirmDelete(subject.id),
          ),
        ],
      ),
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
                  : const Text('هل أنت متأكد من حذف هذه المادة؟'),
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
                          await _firestoreService.deleteSubject(id);
                          Navigator.pop(context);
                          _loadSubjects();
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

  void _showAddSubjectPage(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AddSubjectScreen()),
    ).then((_) => _loadSubjects());
  }

  void _confirmSendAbsenceAlert(SubjectModel subject) {
    showDialog(
      context: context,
      builder: (context) {
        bool innerLoading = false;
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('إرسال تنبيه غياب'),
              content: innerLoading
                  ? const SizedBox(
                      height: 100,
                      child: Center(child: CircularProgressIndicator()),
                    )
                  : Text(
                      'هل تريد إرسال تنبيه بالغياب للطلاب غير الحاضرين في مادة "${subject.name}" اليوم؟',
                    ),
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
                          try {
                            final count = await _firestoreService
                                .sendAbsenceAlerts(
                                  subjectId: subject.id,
                                  subjectName: subject.name,
                                  date: DateTime.now(),
                                );
                            if (mounted) {
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'تم إرسال تنبيه الغياب لعدد $count طالب',
                                  ),
                                  backgroundColor: ColorsManager.green,
                                ),
                              );
                            }
                          } catch (e) {
                            if (mounted) {
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('حدث خطأ: $e'),
                                  backgroundColor: ColorsManager.red,
                                ),
                              );
                            }
                          }
                        },
                        child: const Text(
                          'إرسال',
                          style: TextStyle(color: ColorsManager.orange),
                        ),
                      ),
                    ],
            );
          },
        );
      },
    );
  }
}

class AddSubjectScreen extends StatefulWidget {
  const AddSubjectScreen({super.key});

  @override
  State<AddSubjectScreen> createState() => _AddSubjectScreenState();
}

class _AddSubjectScreenState extends State<AddSubjectScreen> {
  final nameController = TextEditingController();
  final FirestoreService _firestoreService = FirestoreService();
  bool _isSaving = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('إضافة مادة جديدة')),
      body: Padding(
        padding: EdgeInsets.all(25.w),
        child: Column(
          children: [
            TextField(
              controller: nameController,
              enabled: !_isSaving,
              decoration: InputDecoration(
                labelText: 'اسم المادة',
                prefixIcon: const Icon(Icons.book, color: ColorsManager.teal),
                filled: true,
                fillColor: ColorsManager.grey100,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15.r),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            SizedBox(height: 20.h),
            const Text(
              'ملاحظة: سيتم إنشاء المادة كغير نشطة. يمكنك تفعيلها عند إضافة دكتور جديد وربطها به.',
              style: TextStyle(color: ColorsManager.grey, fontSize: 13),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 40.h),
            ElevatedButton(
              onPressed: _isSaving
                  ? null
                  : () async {
                      if (nameController.text.isNotEmpty) {
                        setState(() => _isSaving = true);
                        try {
                          await _firestoreService.addSubject(
                            nameController.text,
                          );
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
                  : const Text(
                      'حفظ المادة',
                      style: TextStyle(
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
}

// ─── Edit Subject Students Screen ────────────────────────────────────────────

class EditSubjectStudentsScreen extends StatefulWidget {
  final SubjectModel subject;

  const EditSubjectStudentsScreen({super.key, required this.subject});

  @override
  State<EditSubjectStudentsScreen> createState() =>
      _EditSubjectStudentsScreenState();
}

class _EditSubjectStudentsScreenState extends State<EditSubjectStudentsScreen> {
  final FirestoreService _firestoreService = FirestoreService();

  List<Map<String, dynamic>> _allStudents = [];
  List<Map<String, dynamic>> _filteredStudents = [];
  final TextEditingController _searchController = TextEditingController();

  final Set<String> _selectedIds = {};
  final Set<String> _originalIds = {};

  bool _isLoading = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadData();
    _searchController.addListener(_filterStudents);
  }

  Future<void> _loadData() async {
    try {
      final students = await _firestoreService.getAllStudentsFromDirectory();

      if (mounted) {
        setState(() {
          _allStudents = students;
          _filteredStudents = students;

          final assignedIds = widget.subject.enrolledStudentIds.toSet();
          _selectedIds.addAll(assignedIds);
          _originalIds.addAll(assignedIds);

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

  Future<void> _save() async {
    setState(() => _isSaving = true);
    try {
      await _firestoreService.updateSubjectEnrollment(
        widget.subject.id,
        _selectedIds.toList(),
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تم حفظ التغييرات بنجاح'),
            backgroundColor: ColorsManager.green,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('حدث خطأ: $e'),
            backgroundColor: ColorsManager.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('تخصيص الطلاب للمادة'),
            Text(
              widget.subject.name,
              style: TextStyle(
                fontSize: 13.sp,
                color: ColorsManager.white.withOpacity(0.85),
                fontWeight: FontWeight.normal,
              ),
            ),
          ],
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
        iconTheme: const IconThemeData(color: ColorsManager.white),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Padding(
                  padding: EdgeInsets.all(20.w),
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      labelText: 'بحث برقم الطالب أو الاسم',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15.r),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    padding: EdgeInsets.symmetric(horizontal: 20.w),
                    itemCount: _filteredStudents.length,
                    itemBuilder: (context, index) {
                      final student = _filteredStudents[index];
                      final studentId = student['Student_ID'].toString();
                      final isSelected = _selectedIds.contains(studentId);

                      return CheckboxListTile(
                        title: Text(student['Name'] ?? ''),
                        subtitle: Text('الرقم الجامعي: $studentId'),
                        value: isSelected,
                        onChanged: (bool? value) {
                          setState(() {
                            if (value == true) {
                              _selectedIds.add(studentId);
                            } else {
                              _selectedIds.remove(studentId);
                            }
                          });
                        },
                      );
                    },
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(20.w),
                  child: ElevatedButton.icon(
                    onPressed: _isSaving ? null : _save,
                    icon: _isSaving
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              color: ColorsManager.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Icon(
                            Icons.save_outlined,
                            color: ColorsManager.white,
                          ),
                    label: Text(
                      _isSaving ? 'جاري الحفظ...' : 'حفظ التغييرات',
                      style: const TextStyle(
                        color: ColorsManager.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: ColorsManager.primaryColor,
                      minimumSize: Size(double.infinity, 55.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15.r),
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
