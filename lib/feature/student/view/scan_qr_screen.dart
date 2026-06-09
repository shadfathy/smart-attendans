import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:geolocator/geolocator.dart';
import '../../../core/models/attendance_model.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/services/firestore_service.dart';
import '../../../core/theme/colors.dart';

class ScanQrScreen extends StatefulWidget {
  const ScanQrScreen({super.key});

  @override
  State<ScanQrScreen> createState() => _ScanQrScreenState();
}

class _ScanQrScreenState extends State<ScanQrScreen> {
  final MobileScannerController controller = MobileScannerController();
  bool _isProcessing = false;
  final FirestoreService _firestoreService = FirestoreService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('مسح رمز QR')),
      body: Stack(
        children: [
          MobileScanner(
            controller: controller,
            onDetect: (capture) async {
              if (_isProcessing) return;

              final List<Barcode> barcodes = capture.barcodes;
              if (barcodes.isNotEmpty) {
                final String? code = barcodes.first.rawValue;
                if (code != null) {
                  setState(() => _isProcessing = true);
                  await _handleQrCode(code);
                }
              }
            },
          ),
          if (_isProcessing)
            Container(
              color: ColorsManager.black.withOpacity(0.54),
              child: const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(color: ColorsManager.white),
                    SizedBox(height: 20),
                    Text(
                      'جاري التحقق من البيانات والموقع...',
                      style: TextStyle(color: ColorsManager.white),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _handleQrCode(String code) async {
    final parts = code.split('|');
    if (parts.length < 2) {
      _showError('رمز QR غير صالح');
      return;
    }

    final subjectId = parts[0];
    final subjectName = parts[1];

    // 1. Fetch Session Data from Firestore
    final sessionData = await _firestoreService.getSession(subjectId);
    if (sessionData == null) {
      _showError('لم يتم العثور على جلسة نشطة لهذه المادة');
      return;
    }

    // 2. Check Location if required
    if (sessionData['useLocation'] == true) {
      bool isWithinRange = await _checkLocation(
        targetLat: sessionData['lat'],
        targetLong: sessionData['long'],
        radius: sessionData['radius'],
      );

      if (!isWithinRange) {
        _showError('أنت خارج النطاق المسموح به لتسجيل الحضور');
        return;
      }
    }

    // 3. Record Attendance
    final authService = AuthService();
    final user = await authService.getCurrentUserModel();

    if (user != null) {
      final record = AttendanceRecordModel(
        id: '',
        studentId: user.studentId ?? user.id,
        studentName: user.name,
        subjectId: subjectId,
        subjectName: subjectName,
        timestamp: DateTime.now(),
      );

      await _firestoreService.recordAttendance(record);

      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('تم تسجيل الحضور بنجاح')));
        Navigator.pop(context);
      }
    } else {
      _showError('فشل في استرداد بيانات المستخدم');
    }
  }

  Future<bool> _checkLocation({
    required double targetLat,
    required double targetLong,
    required double radius,
  }) async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.deniedForever) return false;

      Position currentPosition = await Geolocator.getCurrentPosition();
      double distanceInMeters = Geolocator.distanceBetween(
        currentPosition.latitude,
        currentPosition.longitude,
        targetLat,
        targetLong,
      );

      return distanceInMeters <= radius;
    } catch (e) {
      print('Location error: $e');
      return false;
    }
  }

  void _showError(String message) {
    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
      setState(() => _isProcessing = false);
    }
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
}
