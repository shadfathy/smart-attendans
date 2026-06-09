import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
import '../models/subject_model.dart';
import '../models/attendance_model.dart';
import '../models/notification_model.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Student Validation & Management (Directory)
  Future<Map<String, dynamic>?> validateStudent(
    String name,
    String studentId,
  ) async {
    final query = await _db
        .collection('students')
        .where('Name', isEqualTo: name)
        .where('Student_ID', isEqualTo: int.tryParse(studentId) ?? studentId)
        .get();

    if (query.docs.isNotEmpty) {
      return query.docs.first.data();
    }
    return null;
  }

  Future<void> addStudentToDirectory(
    String name,
    String studentId,
    String branch,
    String department,
    String grade,
  ) async {
    await _db.collection('students').add({
      'Name': name,
      'Student_ID': int.tryParse(studentId) ?? studentId,
      'Branch': branch,
      'Department': department,
      'Grade': grade,
    });
  }

  Future<void> updateStudentInDirectory(
    String docId,
    String name,
    String studentId,
    String branch,
    String department,
    String grade,
  ) async {
    await _db.collection('students').doc(docId).update({
      'Name': name,
      'Student_ID': int.tryParse(studentId) ?? studentId,
      'Branch': branch,
      'Department': department,
      'Grade': grade,
    });
  }

  Future<List<Map<String, dynamic>>> getAllStudentsFromDirectory() async {
    final query = await _db.collection('students').get();
    return query.docs.map((doc) => {'id': doc.id, ...doc.data()}).toList();
  }

  Future<void> deleteStudentFromDirectory(String docId) async {
    await _db.collection('students').doc(docId).delete();
  }

  // User Management
  Future<void> createUser(UserModel user) async {
    await _db.collection('users').doc(user.id).set(user.toMap());
  }

  Future<UserModel?> getUser(String uid) async {
    final doc = await _db.collection('users').doc(uid).get();
    if (doc.exists) {
      return UserModel.fromMap(doc.data()!);
    }
    return null;
  }

  Future<List<UserModel>> getDoctors() async {
    final query = await _db
        .collection('users')
        .where('role', isEqualTo: 'doctor')
        .get();
    return query.docs.map((d) => UserModel.fromMap(d.data())).toList();
  }

  Future<void> deleteUser(String uid) async {
    await _db.collection('users').doc(uid).delete();
  }

  // Subject Management
  Future<void> addSubject(String name, {String? doctorId}) async {
    final doc = _db.collection('subjects').doc();
    await doc.set({'id': doc.id, 'name': name, 'doctorId': doctorId});
  }

  Future<void> deleteSubject(String subjectId) async {
    await _db.collection('subjects').doc(subjectId).delete();
  }

  Future<void> assignSubjectToDoctor(String subjectId, String doctorId) async {
    await _db.collection('subjects').doc(subjectId).update({
      'doctorId': doctorId,
    });
  }

  Future<void> unassignSubjectFromDoctor(String subjectId) async {
    await _db.collection('subjects').doc(subjectId).update({'doctorId': null});
  }

  Future<List<SubjectModel>> getUnassignedSubjects() async {
    final query = await _db
        .collection('subjects')
        .where('doctorId', isNull: true)
        .get();
    return query.docs.map((doc) => SubjectModel.fromMap(doc.data())).toList();
  }

  Future<List<SubjectModel>> getAllSubjects() async {
    final query = await _db.collection('subjects').get();
    return query.docs.map((doc) => SubjectModel.fromMap(doc.data())).toList();
  }

  Future<List<SubjectModel>> getDoctorSubjects(String doctorId) async {
    final query = await _db
        .collection('subjects')
        .where('doctorId', isEqualTo: doctorId)
        .get();
    return query.docs.map((doc) => SubjectModel.fromMap(doc.data())).toList();
  }

  // Attendance Management
  Future<void> recordAttendance(AttendanceRecordModel record) async {
    await _db.collection('attendance').add(record.toMap());
  }

  Future<List<AttendanceRecordModel>> getStudentHistory(
    String studentId,
  ) async {
    final query = await _db
        .collection('attendance')
        .where('studentId', isEqualTo: studentId)
        .get();

    final records = query.docs
        .map((d) => AttendanceRecordModel.fromMap(d.data()))
        .toList();
    records.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return records;
  }

  Future<List<AttendanceRecordModel>> getSubjectHistory(
    String subjectId,
  ) async {
    final query = await _db
        .collection('attendance')
        .where('subjectId', isEqualTo: subjectId)
        .get();

    final records = query.docs
        .map((d) => AttendanceRecordModel.fromMap(d.data()))
        .toList();
    records.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return records;
  }

  Future<List<AttendanceRecordModel>> getAllAttendance() async {
    final query = await _db.collection('attendance').get();

    final records = query.docs
        .map((d) => AttendanceRecordModel.fromMap(d.data()))
        .toList();
    records.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return records;
  }

  // Session & Location Management
  Future<void> updateSession({
    required String subjectId,
    required bool useLocation,
    required double lat,
    required double long,
    required double radius,
  }) async {
    await _db.collection('sessions').doc(subjectId).set({
      'useLocation': useLocation,
      'lat': lat,
      'long': long,
      'radius': radius,
      'lastUpdated': FieldValue.serverTimestamp(),
    });
  }

  Future<Map<String, dynamic>?> getSession(String subjectId) async {
    final doc = await _db.collection('sessions').doc(subjectId).get();
    return doc.data();
  }

  // ─── Enrollment Management ──────────────────────────────────────────────────

  Future<void> updateSubjectEnrollment(
    String subjectId,
    List<String> studentIds,
  ) async {
    await _db.collection('subjects').doc(subjectId).update({
      'enrolledStudentIds': studentIds,
    });
  }

  Future<void> enrollStudentInSubject(
    String subjectId,
    String studentId,
  ) async {
    await _db.collection('subjects').doc(subjectId).update({
      'enrolledStudentIds': FieldValue.arrayUnion([studentId]),
    });
  }

  Future<void> unenrollStudentFromSubject(
    String subjectId,
    String studentId,
  ) async {
    await _db.collection('subjects').doc(subjectId).update({
      'enrolledStudentIds': FieldValue.arrayRemove([studentId]),
    });
  }

  // ─── Notification / Absence Alerts ──────────────────────────────────────────

  /// Gets attendance records for a subject on a specific date.
  Future<List<AttendanceRecordModel>> getAttendanceForSubjectOnDate(
    String subjectId,
    DateTime date,
  ) async {
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    final query = await _db
        .collection('attendance')
        .where('subjectId', isEqualTo: subjectId)
        .where(
          'timestamp',
          isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay),
        )
        .where('timestamp', isLessThan: Timestamp.fromDate(endOfDay))
        .get();

    return query.docs
        .map((d) => AttendanceRecordModel.fromMap(d.data()))
        .toList();
  }

  /// Sends absence alerts to enrolled students who didn't attend.
  /// Returns the number of alerts sent.
  Future<int> sendAbsenceAlerts({
    required String subjectId,
    required String subjectName,
    required DateTime date,
  }) async {
    log(subjectId);
    // 1. Get the subject to find enrolled students
    final subjectDoc = await _db.collection('subjects').doc(subjectId).get();
    if (!subjectDoc.exists) return 0;

    final enrolledIds = List<String>.from(
      subjectDoc.data()?['enrolledStudentIds'] ?? [],
    );
    log('Enrolled IDs: $enrolledIds');
    if (enrolledIds.isEmpty) {
      log('No enrolled students found.');
      return 0;
    }

    // 2. Get attendance records for this subject on this date
    final attendanceRecords = await getAttendanceForSubjectOnDate(
      subjectId,
      date,
    );
    final attendedStudentIds = attendanceRecords
        .map((r) => r.studentId)
        .toSet();
    log('Attended IDs: $attendedStudentIds');

    // 3. Find absent students
    final absentStudentIds = enrolledIds
        .where((id) => !attendedStudentIds.contains(id))
        .toList();
    log('Absent IDs: $absentStudentIds');
    if (absentStudentIds.isEmpty) {
      log('No absent students found.');
      return 0;
    }

    // 4. Format date for message
    final dateStr =
        '${date.year}/${date.month.toString().padLeft(2, '0')}/${date.day.toString().padLeft(2, '0')}';
    final message = 'لم يتم تسجيل حضورك في محاضرة $subjectName بتاريخ $dateStr';

    // 5. Write notification for each absent student
    final batch = _db.batch();
    for (final studentId in absentStudentIds) {
      final docRef = _db.collection('notifications').doc();
      batch.set(docRef, {
        'id': docRef.id,
        'studentId': studentId,
        'subjectId': subjectId,
        'subjectName': subjectName,
        'message': message,
        'timestamp': FieldValue.serverTimestamp(),
        'isRead': false,
      });
    }
    await batch.commit();

    return absentStudentIds.length;
  }

  /// Fetches all notifications for a student, ordered by newest first.
  Future<List<NotificationModel>> getStudentNotifications(
    String studentId,
  ) async {
    final query = await _db
        .collection('notifications')
        .where('studentId', isEqualTo: studentId)
        .orderBy('timestamp', descending: true)
        .get();

    return query.docs.map((d) => NotificationModel.fromMap(d.data())).toList();
  }

  /// Returns count of unread notifications for a student.
  Future<int> getUnreadNotificationCount(String studentId) async {
    final query = await _db
        .collection('notifications')
        .where('studentId', isEqualTo: studentId)
        .where('isRead', isEqualTo: false)
        .get();

    return query.docs.length;
  }

  /// Marks a single notification as read.
  Future<void> markNotificationAsRead(String notificationId) async {
    await _db.collection('notifications').doc(notificationId).update({
      'isRead': true,
    });
  }

  /// Marks all notifications for a student as read.
  Future<void> markAllNotificationsAsRead(String studentId) async {
    final query = await _db
        .collection('notifications')
        .where('studentId', isEqualTo: studentId)
        .where('isRead', isEqualTo: false)
        .get();

    final batch = _db.batch();
    for (final doc in query.docs) {
      batch.update(doc.reference, {'isRead': true});
    }
    await batch.commit();
  }
}
