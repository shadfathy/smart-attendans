class UserModel {
  final String id;
  final String name;
  final String email;
  final String role; // 'admin', 'doctor', 'student'
  final String? studentId;
  final bool isDoctor;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.studentId,
    this.isDoctor = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'role': role,
      'studentId': studentId,
      'isDoctor': isDoctor,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      role: map['role'] ?? 'student',
      studentId: map['studentId'],
      isDoctor: map['isDoctor'] ?? false,
    );
  }
}
