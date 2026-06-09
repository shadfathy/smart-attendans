import 'package:cloud_firestore/cloud_firestore.dart';

class AttendanceRecordModel {
  final String id;
  final String studentId;
  final String studentName;
  final String subjectId;
  final String subjectName;
  final DateTime timestamp;

  AttendanceRecordModel({
    required this.id,
    required this.studentId,
    required this.studentName,
    required this.subjectId,
    required this.subjectName,
    required this.timestamp,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'studentId': studentId,
      'studentName': studentName,
      'subjectId': subjectId,
      'subjectName': subjectName,
      'timestamp': Timestamp.fromDate(timestamp),
    };
  }

  factory AttendanceRecordModel.fromMap(Map<String, dynamic> map) {
    return AttendanceRecordModel(
      id: map['id'] ?? '',
      studentId: map['studentId'] ?? '',
      studentName: map['studentName'] ?? '',
      subjectId: map['subjectId'] ?? '',
      subjectName: map['subjectName'] ?? '',
      timestamp: (map['timestamp'] as Timestamp).toDate(),
    );
  }
}
