import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/services/biometric_service.dart';

class LoginViewModel {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  // Student controllers
  final nameController = TextEditingController();
  final idController = TextEditingController();

  final ValueNotifier<bool> isLoading = ValueNotifier(false);
  final AuthService _authService = AuthService();
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Biometric authentication
  final BiometricService _biometricService = BiometricService();
  final ValueNotifier<bool> canUseBiometric = ValueNotifier(false);
  final ValueNotifier<bool> hasStoredCredentials = ValueNotifier(false);
  final ValueNotifier<bool> isBiometricLoading = ValueNotifier(false);

  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    nameController.dispose();
    idController.dispose();
    isLoading.dispose();
    canUseBiometric.dispose();
    hasStoredCredentials.dispose();
    isBiometricLoading.dispose();
  }

  /// Initialize biometric authentication - check device capability and stored credentials
  Future<void> initBiometric() async {
    final isAvailable = await _biometricService.isBiometricAvailable();
    canUseBiometric.value = isAvailable;

    if (isAvailable) {
      hasStoredCredentials.value = await _biometricService
          .hasStoredCredentials();
    }
  }

  /// Login with biometric authentication
  /// Note: Skip Firestore verification since credentials were validated during first login
  Future<void> loginWithBiometric(BuildContext context) async {
    if (!canUseBiometric.value || !hasStoredCredentials.value) {
      return;
    }

    isBiometricLoading.value = true;
    try {
      final authenticated = await _biometricService.authenticate();
      if (!authenticated) {
        _showError(context, 'فشل التحقق من البصمة');
        return;
      }

      final credentials = await _biometricService.getStoredCredentials();
      if (credentials == null) {
        _showError(context, 'لم يتم العثور على بيانات محفوظة');
        return;
      }

      // Use stored credentials for auto-login
      nameController.text = credentials.name;
      idController.text = credentials.studentId;

      // Directly sign in with Firebase Auth (skip Firestore verification
      // since credentials were already validated during first manual login)
      final String studentEmail =
          "${credentials.studentId}@smart-attendance.com";
      final String studentPassword = credentials.studentId;

      final result = await _authService.signIn(studentEmail, studentPassword);

      if (result != null) {
        Navigator.pushReplacementNamed(context, '/student_dashboard');
      } else {
        // If sign-in fails, credentials may be stale - clear them
        await _biometricService.clearCredentials();
        hasStoredCredentials.value = false;
        _showError(context, 'فشل تسجيل الدخول. يرجى تسجيل الدخول يدوياً.');
      }
    } catch (e) {
      _showError(context, 'حدث خطأ أثناء تسجيل الدخول بالبصمة');
    } finally {
      isBiometricLoading.value = false;
    }
  }

  // Traditional Login (Email/Password) for Doctors/Admins
  Future<void> login(BuildContext context) async {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      _showError(context, 'يرجى إدخال البريد الإلكتروني وكلمة المرور');
      return;
    }

    isLoading.value = true;
    try {
      // Special case for SuperAdmin
      if (email == 'admin@smartattendance.com' && password == '123456') {
        var result = await _authService.signIn(email, password);
        result ??= await _authService.signUp(email, password, 'Admin', null);

        if (result != null) {
          Navigator.pushReplacementNamed(context, '/admin_dashboard');
        } else {
          _showError(context, 'فشل تسجيل دخول المسؤول');
        }
        return;
      }

      final result = await _authService.signIn(email, password);
      if (result != null) {
        await _navigateByRole(context);
      } else {
        _showError(context, 'البريد الإلكتروني أو كلمة المرور غير صحيحة');
      }
    } catch (e) {
      _showError(context, 'حدث خطأ: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // Direct Student Login (Name/ID) - No registration needed!
  Future<void> loginAsStudent(BuildContext context) async {
    String name = nameController.text.trim().replaceAll(RegExp(r'\s+'), ' ');
    final id = idController.text.trim();

    if (name.isEmpty || id.isEmpty) {
      _showError(context, 'يرجى إدخال الاسم والرقم الجامعي');
      return;
    }

    isLoading.value = true;
    try {
      await _performStudentLogin(context, name, id, saveCredentials: true);
    } finally {
      isLoading.value = false;
    }
  }

  /// Core student login logic - used by both manual and biometric login
  Future<void> _performStudentLogin(
    BuildContext context,
    String name,
    String id, {
    bool saveCredentials = false,
  }) async {
    // 1. Verify that the student exists in the UNIVERSITY DIRECTORY (students collection)
    var studentQuery = await _db
        .collection('students')
        .where('Name', isEqualTo: name)
        .where('Student_ID', isEqualTo: int.tryParse(id) ?? id)
        .get();

    if (studentQuery.docs.isEmpty) {
      _showError(
        context,
        'بيانات الطالب غير موجودة في سجلات الجامعة. تأكد من كتابة الاسم والاسم الرباعي بشكل صحيح.',
      );
      return;
    }

    // 2. We found the student! Now let's log them into Firebase.
    // We use their ID as a hidden email and password.
    final String studentEmail = "$id@smart-attendance.com";
    final String studentPassword = id;

    // Try to sign in
    var result = await _authService.signIn(studentEmail, studentPassword);

    // 3. If they don't have an account yet, create one automatically in the background
    result ??= await _authService.signUp(
      studentEmail,
      studentPassword,
      name,
      id,
    );

    if (result != null) {
      // Save credentials for future biometric login
      if (saveCredentials && canUseBiometric.value) {
        await _biometricService.saveStudentCredentials(
          name: name,
          studentId: id,
        );
        hasStoredCredentials.value = true;
      }
      Navigator.pushReplacementNamed(context, '/student_dashboard');
    } else {
      _showError(context, 'فشل في تهيئة حساب الطالب. يرجى المحاولة لاحقاً.');
    }
  }

  Future<void> _navigateByRole(BuildContext context) async {
    final userModel = await _authService.getCurrentUserModel();
    if (userModel != null) {
      if (userModel.role == 'doctor' || userModel.isDoctor) {
        Navigator.pushReplacementNamed(context, '/doctor_dashboard');
      } else {
        Navigator.pushReplacementNamed(context, '/student_dashboard');
      }
    } else {
      _showError(context, 'فشل في استرداد بيانات المستخدم');
    }
  }

  void _showError(BuildContext context, String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  void goToRegister(BuildContext context) {
    Navigator.pushNamed(context, AppRoutes.register);
  }
}
