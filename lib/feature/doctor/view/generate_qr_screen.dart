import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:geolocator/geolocator.dart';
import '../../../core/models/subject_model.dart';
import '../../../core/services/firestore_service.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/text_styles.dart';

class GenerateQrScreen extends StatefulWidget {
  const GenerateQrScreen({super.key});

  @override
  State<GenerateQrScreen> createState() => _GenerateQrScreenState();
}

class _GenerateQrScreenState extends State<GenerateQrScreen> {
  late SubjectModel _subject;
  String _qrData = '';
  bool _useLocation = false;
  double _radius = 50.0;
  Position? _currentPosition;
  bool _isFetchingLocation = false;
  final FirestoreService _firestoreService = FirestoreService();
  Timer? _timer;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _subject = ModalRoute.of(context)!.settings.arguments as SubjectModel;
    _generateNewCode();
    _startTimer();
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 30), (timer) {
      if (mounted) {
        _generateNewCode();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _getCurrentLocation() async {
    setState(() => _isFetchingLocation = true);
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.whileInUse ||
          permission == LocationPermission.always) {
        Position position = await Geolocator.getCurrentPosition();
        setState(() {
          _currentPosition = position;
          _isFetchingLocation = false;
        });
      }
    } catch (e) {
      setState(() => _isFetchingLocation = false);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('خطأ في تحديد الموقع: $e')));
      }
    }
  }

  void _generateNewCode() async {
    // QR data format: "subjectId|subjectName|timestamp"
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    setState(() {
      _qrData = '${_subject.id}|${_subject.name}|$timestamp';
    });

    // Restart timer when manually generating a new code
    _startTimer();

    // Update session in Firestore
    await _firestoreService.updateSession(
      subjectId: _subject.id,
      useLocation: _useLocation,
      lat: _currentPosition?.latitude ?? 0.0,
      long: _currentPosition?.longitude ?? 0.0,
      radius: _radius,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('توليد رمز QR')),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(20.w),
          child: Column(
            children: [
              Text(
                _subject.name,
                style: TextStyles.font20White500Weight(context).copyWith(
                  color: ColorsManager.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 22.sp,
                ),
              ),
              SizedBox(height: 20.h),

              // Location Settings Card
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15.r),
                ),
                child: Padding(
                  padding: EdgeInsets.all(15.w),
                  child: Column(
                    children: [
                      SwitchListTile(
                        title: const Text('تفعيل التحقق من الموقع'),
                        value: _useLocation,
                        onChanged: (val) {
                          setState(() => _useLocation = val);
                          if (val && _currentPosition == null) {
                            _getCurrentLocation();
                          }
                        },
                      ),
                      if (_useLocation) ...[
                        const Divider(),
                        if (_isFetchingLocation)
                          const CircularProgressIndicator()
                        else if (_currentPosition != null)
                          Text(
                            'الموقع الحالي: ${_currentPosition!.latitude.toStringAsFixed(4)}, ${_currentPosition!.longitude.toStringAsFixed(4)}',
                          )
                        else
                          ElevatedButton.icon(
                            onPressed: _getCurrentLocation,
                            icon: const Icon(Icons.location_on),
                            label: const Text('تحديد موقعي الحالي'),
                          ),
                        SizedBox(height: 10.h),
                        Row(
                          children: [
                            const Text('نطاق السماح (متر):'),
                            Expanded(
                              child: Slider(
                                value: _radius,
                                min: 10,
                                max: 500,
                                divisions: 49,
                                label: _radius.round().toString(),
                                onChanged: (val) =>
                                    setState(() => _radius = val),
                              ),
                            ),
                            Text('${_radius.round()} م'),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ),

              SizedBox(height: 30.h),

              Container(
                padding: EdgeInsets.all(20.w),
                decoration: BoxDecoration(
                  color: ColorsManager.white,
                  borderRadius: BorderRadius.circular(20.r),
                  boxShadow: [
                    BoxShadow(
                      color: ColorsManager.black.withOpacity(0.1),
                      blurRadius: 20,
                    ),
                  ],
                ),
                child: QrImageView(
                  data: _qrData,
                  version: QrVersions.auto,
                  size: 200.w,
                  backgroundColor: ColorsManager.white,
                ),
              ),

              SizedBox(height: 30.h),
              ElevatedButton.icon(
                onPressed: _generateNewCode,
                icon: const Icon(Icons.refresh),
                label: const Text('تحديث الرمز وتفعيل الجلسة'),
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(
                    horizontal: 30.w,
                    vertical: 15.h,
                  ),
                  backgroundColor: ColorsManager.teal,
                  foregroundColor: ColorsManager.white,
                  minimumSize: Size(double.infinity, 50.h),
                ),
              ),
              SizedBox(height: 15.h),
              ElevatedButton.icon(
                onPressed: () => _confirmEndSessionAndAlert(),
                icon: const Icon(Icons.notifications_active),
                label: const Text('إنهاء المحاضرة وتنبيه الغائبين'),
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(
                    horizontal: 30.w,
                    vertical: 15.h,
                  ),
                  backgroundColor: ColorsManager.red,
                  foregroundColor: ColorsManager.white,
                  minimumSize: Size(double.infinity, 50.h),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _confirmEndSessionAndAlert() {
    showDialog(
      context: context,
      builder: (context) {
        bool innerLoading = false;
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('إنهاء وتنبيه'),
              content: innerLoading
                  ? const SizedBox(
                      height: 100,
                      child: Center(child: CircularProgressIndicator()),
                    )
                  : Text(
                      'هل تريد إنهاء محاضرة "${_subject.name}" وإرسال تنبيه بالغياب للطلاب غير الحاضرين؟',
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
                                  subjectId: _subject.id,
                                  subjectName: _subject.name,
                                  date: DateTime.now(),
                                );
                            if (mounted) {
                              Navigator.pop(context); // Close dialog
                              Navigator.pop(context); // Go back to dashboard
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'تم إنهاء المحاضرة وإرسال تنبيه الغياب لعدد $count طالب',
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
                          'تأكيد',
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
}
