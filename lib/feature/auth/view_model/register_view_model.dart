import 'package:flutter/material.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/services/firestore_service.dart';

class RegisterViewModel {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final facultyIdController = TextEditingController();
  final fullNameController = TextEditingController();
  final ValueNotifier<bool> isLoading = ValueNotifier(false);

  final AuthService _authService = AuthService();
  final FirestoreService _firestoreService = FirestoreService();

  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    facultyIdController.dispose();
    fullNameController.dispose();
    isLoading.dispose();
  }

  Future<void> register(BuildContext context) async {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();
    final confirmPassword = confirmPasswordController.text.trim();
    final facultyId = facultyIdController.text.trim();
    final fullName = fullNameController.text.trim();

    if (email.isEmpty ||
        password.isEmpty ||
        confirmPassword.isEmpty ||
        facultyId.isEmpty ||
        fullName.isEmpty) {
      _showError(context, 'يرجى إكمال جميع الحقول');
      return;
    }

    if (password != confirmPassword) {
      _showError(context, 'كلمات المرور غير متطابقة');
      return;
    }

    isLoading.value = true;
    try {
      // 1. Validate student against Firestore students collection
      final studentData = await _firestoreService.validateStudent(
        fullName,
        facultyId,
      );
      if (studentData == null) {
        _showError(context, 'بيانات الطالب غير موجودة في قاعدة البيانات');
        return;
      }

      // 2. Register in Firebase Auth
      final result = await _authService.signUp(
        email,
        password,
        fullName,
        facultyId,
      );
      if (result != null) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('تم إنشاء الحساب بنجاح')));
        Navigator.pop(context);
      } else {
        _showError(context, 'حدث خطأ أثناء إنشاء الحساب');
      }
    } catch (e) {
      _showError(context, 'حدث خطأ غير متوقع: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void _showError(BuildContext context, String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  void goBack(BuildContext context) {
    Navigator.pop(context);
  }
}
