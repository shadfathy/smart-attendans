import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class BiometricService {
  final LocalAuthentication _localAuth = LocalAuthentication();
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  static const String _keyStudentName = 'student_name';
  static const String _keyStudentId = 'student_id';

  /// Check if biometric authentication is available on the device
  Future<bool> isBiometricAvailable() async {
    try {
      final bool canAuthenticateWithBiometrics =
          await _localAuth.canCheckBiometrics;
      final bool canAuthenticate =
          canAuthenticateWithBiometrics || await _localAuth.isDeviceSupported();

      if (!canAuthenticate) return false;

      // Check if there are enrolled biometrics
      final List<BiometricType> availableBiometrics =
          await _localAuth.getAvailableBiometrics();

      return availableBiometrics.isNotEmpty;
    } on PlatformException {
      return false;
    }
  }

  /// Trigger biometric authentication prompt
  Future<bool> authenticate() async {
    try {
      return await _localAuth.authenticate(
        localizedReason: 'قم بتأكيد هويتك للدخول',
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: true,
        ),
      );
    } on PlatformException {
      return false;
    }
  }

  /// Save student credentials after successful login
  Future<void> saveStudentCredentials({
    required String name,
    required String studentId,
  }) async {
    await _secureStorage.write(key: _keyStudentName, value: name);
    await _secureStorage.write(key: _keyStudentId, value: studentId);
  }

  /// Check if there are stored credentials for returning student
  Future<bool> hasStoredCredentials() async {
    final name = await _secureStorage.read(key: _keyStudentName);
    final id = await _secureStorage.read(key: _keyStudentId);
    return name != null && name.isNotEmpty && id != null && id.isNotEmpty;
  }

  /// Retrieve stored credentials for auto-login
  Future<({String name, String studentId})?> getStoredCredentials() async {
    final name = await _secureStorage.read(key: _keyStudentName);
    final id = await _secureStorage.read(key: _keyStudentId);

    if (name != null && name.isNotEmpty && id != null && id.isNotEmpty) {
      return (name: name, studentId: id);
    }
    return null;
  }

  /// Clear stored credentials (for logout)
  Future<void> clearCredentials() async {
    await _secureStorage.delete(key: _keyStudentName);
    await _secureStorage.delete(key: _keyStudentId);
  }
}
