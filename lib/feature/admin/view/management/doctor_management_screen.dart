import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/services/firestore_service.dart';
import '../../../../core/theme/colors.dart';
import '../../../../core/services/auth_service.dart';
import '../../../../core/models/user_model.dart';
import '../../../../core/models/subject_model.dart';

class DoctorManagementScreen extends StatefulWidget {
  const DoctorManagementScreen({super.key});

  @override
  State<DoctorManagementScreen> createState() => _DoctorManagementScreenState();
}

class _DoctorManagementScreenState extends State<DoctorManagementScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  List<UserModel> _doctors = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDoctors();
  }

  Future<void> _loadDoctors() async {
    try {
      setState(() => _isLoading = true);
      final doctors = await _firestoreService.getDoctors();
      if (mounted) {
        setState(() {
          _doctors = doctors;
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
        title: const Text(
          'إدارة الدكاترة',
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
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _doctors.isEmpty
          ? const Center(child: Text('لا يوجد دكاترة مضافين'))
          : ListView.builder(
              padding: EdgeInsets.all(20.w),
              itemCount: _doctors.length,
              itemBuilder: (context, index) {
                final doctor = _doctors[index];
                return _buildDoctorCard(doctor);
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddDoctorPage(context),
        backgroundColor: ColorsManager.teal,
        child: const Icon(Icons.person_add, color: ColorsManager.white),
      ),
    );
  }

  Widget _buildDoctorCard(UserModel doctor) {
    return Container(
      margin: EdgeInsets.only(bottom: 15.h),
      padding: EdgeInsets.all(15.w),
      decoration: BoxDecoration(
        color: ColorsManager.white,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: ColorsManager.black.withValues(alpha: 0.05),
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
              color: ColorsManager.teal.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.supervisor_account,
              color: ColorsManager.teal,
              size: 25.w,
            ),
          ),
          SizedBox(width: 15.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  doctor.name,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16.sp,
                  ),
                ),
                Text(
                  doctor.email,
                  style: TextStyle(color: ColorsManager.grey, fontSize: 12.sp),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(
              Icons.book_outlined,
              color: ColorsManager.primaryColor,
            ),
            tooltip: 'تعديل المواد',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      EditDoctorSubjectsScreen(doctor: doctor),
                ),
              ).then((_) => _loadDoctors());
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, color: ColorsManager.red),
            onPressed: () => _confirmDelete(doctor.id),
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
                  : const Text('هل أنت متأكد من حذف هذا الدكتور؟'),
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
                          await _firestoreService.deleteUser(id);
                          Navigator.pop(context);
                          _loadDoctors();
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

  void _showAddDoctorPage(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AddDoctorScreen()),
    ).then((_) => _loadDoctors());
  }
}

class AddDoctorScreen extends StatefulWidget {
  const AddDoctorScreen({super.key});

  @override
  State<AddDoctorScreen> createState() => _AddDoctorScreenState();
}

class _AddDoctorScreenState extends State<AddDoctorScreen> {
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final FirestoreService _firestoreService = FirestoreService();
  final AuthService _authService = AuthService();
  final _formKey = GlobalKey<FormState>();

  List<SubjectModel> _unassignedSubjects = [];
  final List<String> _selectedSubjectIds = [];
  bool _loadingSubjects = true;
  bool _isSaving = false;
  bool _isPasswordObscured = true;

  @override
  void initState() {
    super.initState();
    _loadUnassignedSubjects();
  }

  Future<void> _loadUnassignedSubjects() async {
    try {
      final subjects = await _firestoreService.getUnassignedSubjects();
      if (mounted) {
        setState(() {
          _unassignedSubjects = subjects;
          _loadingSubjects = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _loadingSubjects = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('إضافة دكتور جديد')),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(25.w),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTextField(
                nameController,
                'اسم الدكتور',
                Icons.person,
                ColorsManager.teal,
                validator: (val) {
                  if (val == null || val.isEmpty) {
                    return 'يرجى إدخال اسم الدكتور';
                  }
                  return null;
                },
              ),
              _buildTextField(
                emailController,
                'البريد الإلكتروني',
                Icons.email,
                ColorsManager.teal,
                validator: (val) {
                  final emailRegex = RegExp(
                    r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                  );

                  if (val == null || val.isEmpty) {
                    return 'يرجى إدخال البريد الإلكتروني';
                  }
                  if (!emailRegex.hasMatch(val)) {
                    return 'يرجى إدخال بريد إلكتروني صحيح';
                  }
                  return null;
                },
              ),
              _buildTextField(
                passwordController,
                'كلمة المرور',
                Icons.lock,
                ColorsManager.teal,
                isPassword: true,
                validator: (val) {
                  if (val == null || val.isEmpty) {
                    return 'يرجى إدخال كلمة المرور';
                  }
                  if (val.length < 6) {
                    return 'كلمة المرور يجب أن تكون 6 أحرف على الأقل';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20.h),

              Text(
                'اختر المواد الدراسية:',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                  color: ColorsManager.teal,
                ),
              ),
              SizedBox(height: 10.h),
              _loadingSubjects
                  ? const Center(child: CircularProgressIndicator())
                  : _unassignedSubjects.isEmpty
                  ? const Text(
                      'لا توجد مواد غير مسندة حالياً',
                      style: TextStyle(color: ColorsManager.grey),
                    )
                  : Wrap(
                      spacing: 8.w,
                      runSpacing: 8.h,
                      children: _unassignedSubjects.map((subject) {
                        final isSelected = _selectedSubjectIds.contains(
                          subject.id,
                        );
                        return FilterChip(
                          label: Text(subject.name),
                          selected: isSelected,
                          onSelected: _isSaving
                              ? null
                              : (selected) {
                                  setState(() {
                                    if (selected) {
                                      _selectedSubjectIds.add(subject.id);
                                    } else {
                                      _selectedSubjectIds.remove(subject.id);
                                    }
                                  });
                                },
                          selectedColor: ColorsManager.teal.withValues(
                            alpha: 0.2,
                          ),
                          checkmarkColor: ColorsManager.teal,
                          labelStyle: TextStyle(
                            color: isSelected
                                ? ColorsManager.teal
                                : ColorsManager.black,
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                        );
                      }).toList(),
                    ),

              SizedBox(height: 40.h),
              ElevatedButton(
                onPressed: _isSaving
                    ? null
                    : () async {
                        if (_formKey.currentState!.validate()) {
                          setState(() => _isSaving = true);
                          try {
                            final result = await _authService.signUp(
                              emailController.text,
                              passwordController.text,
                              nameController.text,
                              null,
                              isDoctor: true,
                            );

                            if (result != null &&
                                _selectedSubjectIds.isNotEmpty) {
                              for (var id in _selectedSubjectIds) {
                                await _firestoreService.assignSubjectToDoctor(
                                  id,
                                  result.user!.uid,
                                );
                              }
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
                    ? const CircularProgressIndicator(
                        color: ColorsManager.white,
                      )
                    : const Text(
                        'حفظ الدكتور والمواد',
                        style: TextStyle(
                          color: ColorsManager.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label,
    IconData icon,
    Color color, {
    bool isPassword = false,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: 20.h),
      child: TextFormField(
        controller: controller,
        validator: validator,
        obscureText: isPassword ? _isPasswordObscured : false,
        enabled: !_isSaving,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: color),
          suffixIcon: isPassword
              ? IconButton(
                  icon: Icon(
                    _isPasswordObscured
                        ? Icons.visibility_off
                        : Icons.visibility,
                    color: color,
                  ),
                  onPressed: () {
                    setState(() {
                      _isPasswordObscured = !_isPasswordObscured;
                    });
                  },
                )
              : null,
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

// ─── Edit Doctor Subjects Screen ────────────────────────────────────────────

class EditDoctorSubjectsScreen extends StatefulWidget {
  final UserModel doctor;

  const EditDoctorSubjectsScreen({super.key, required this.doctor});

  @override
  State<EditDoctorSubjectsScreen> createState() =>
      _EditDoctorSubjectsScreenState();
}

class _EditDoctorSubjectsScreenState extends State<EditDoctorSubjectsScreen> {
  final FirestoreService _firestoreService = FirestoreService();

  List<SubjectModel> _allSubjects = [];
  // IDs of subjects currently selected (to be assigned to this doctor)
  final Set<String> _selectedIds = {};
  // IDs of subjects that were originally assigned to this doctor (for diffing)
  final Set<String> _originalIds = {};

  bool _isLoading = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      // Load ALL subjects so we can show assigned + unassigned
      final all = await _firestoreService.getAllSubjects();
      // Load the subjects already assigned to this doctor
      final doctorSubjects = await _firestoreService.getDoctorSubjects(
        widget.doctor.id,
      );
      final assignedIds = doctorSubjects.map((s) => s.id).toSet();

      if (mounted) {
        setState(() {
          // Only show subjects that are either unassigned or assigned to THIS doctor
          _allSubjects = all.where((s) {
            return s.doctorId == null || s.doctorId == widget.doctor.id;
          }).toList();
          _selectedIds
            ..clear()
            ..addAll(assignedIds);
          _originalIds
            ..clear()
            ..addAll(assignedIds);
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _save() async {
    setState(() => _isSaving = true);
    try {
      // Subjects to assign (newly checked that weren't before)
      final toAssign = _selectedIds.difference(_originalIds);
      // Subjects to unassign (were checked before but now unchecked)
      final toUnassign = _originalIds.difference(_selectedIds);

      for (final id in toAssign) {
        await _firestoreService.assignSubjectToDoctor(id, widget.doctor.id);
      }
      for (final id in toUnassign) {
        await _firestoreService.unassignSubjectFromDoctor(id);
      }

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
            const Text('تعديل مواد الدكتور'),
            Text(
              widget.doctor.name,
              style: TextStyle(
                fontSize: 13.sp,
                color: ColorsManager.white.withValues(alpha: 0.85),
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
                // Info header
                Container(
                  width: double.infinity,
                  margin: EdgeInsets.all(20.w),
                  padding: EdgeInsets.all(15.w),
                  decoration: BoxDecoration(
                    color: ColorsManager.primaryColor.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(15.r),
                    border: Border.all(
                      color: ColorsManager.primaryColor.withValues(alpha: 0.2),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.info_outline,
                        color: ColorsManager.primaryColor,
                      ),
                      SizedBox(width: 10.w),
                      Expanded(
                        child: Text(
                          'اختر المواد التي تريد تكليف الدكتور بتدريسها. المواد المحددة حالياً باللون الأساسي.',
                          style: TextStyle(
                            fontSize: 13.sp,
                            color: ColorsManager.primaryColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Subject chips
                Expanded(
                  child: _allSubjects.isEmpty
                      ? Center(
                          child: Text(
                            'لا توجد مواد متاحة للإسناد',
                            style: TextStyle(
                              fontSize: 16.sp,
                              color: ColorsManager.grey,
                            ),
                          ),
                        )
                      : ListView.builder(
                          padding: EdgeInsets.symmetric(horizontal: 20.w),
                          itemCount: _allSubjects.length,
                          itemBuilder: (context, index) {
                            final subject = _allSubjects[index];
                            final isSelected = _selectedIds.contains(
                              subject.id,
                            );
                            return _buildSubjectTile(subject, isSelected);
                          },
                        ),
                ),

                // Save button
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

  Widget _buildSubjectTile(SubjectModel subject, bool isSelected) {
    return GestureDetector(
      onTap: _isSaving
          ? null
          : () {
              setState(() {
                if (isSelected) {
                  _selectedIds.remove(subject.id);
                } else {
                  _selectedIds.add(subject.id);
                }
              });
            },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: EdgeInsets.only(bottom: 12.h),
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
        decoration: BoxDecoration(
          color: isSelected
              ? ColorsManager.primaryColor.withValues(alpha: 0.1)
              : ColorsManager.white,
          borderRadius: BorderRadius.circular(15.r),
          border: Border.all(
            color: isSelected
                ? ColorsManager.primaryColor
                : ColorsManager.grey100,
            width: isSelected ? 1.5 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: ColorsManager.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: EdgeInsets.all(10.w),
              decoration: BoxDecoration(
                color: isSelected
                    ? ColorsManager.primaryColor.withValues(alpha: 0.15)
                    : ColorsManager.grey100,
                shape: BoxShape.circle,
              ),
              child: Icon(
                isSelected ? Icons.book : Icons.book_outlined,
                color: isSelected
                    ? ColorsManager.primaryColor
                    : ColorsManager.grey,
                size: 20.w,
              ),
            ),
            SizedBox(width: 15.w),
            Expanded(
              child: Text(
                subject.name,
                style: TextStyle(
                  fontSize: 15.sp,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected
                      ? ColorsManager.primaryColor
                      : ColorsManager.black,
                ),
              ),
            ),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: isSelected
                  ? Icon(
                      Icons.check_circle,
                      key: const ValueKey('checked'),
                      color: ColorsManager.primaryColor,
                      size: 24.w,
                    )
                  : Icon(
                      Icons.circle_outlined,
                      key: const ValueKey('unchecked'),
                      color: ColorsManager.grey200,
                      size: 24.w,
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
