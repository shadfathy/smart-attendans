class SubjectModel {
  final String id;
  final String name;
  final String? doctorId;
  final List<String> enrolledStudentIds;

  SubjectModel({
    required this.id,
    required this.name,
    this.doctorId,
    this.enrolledStudentIds = const [],
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'doctorId': doctorId,
      'enrolledStudentIds': enrolledStudentIds,
    };
  }

  factory SubjectModel.fromMap(Map<String, dynamic> map) {
    return SubjectModel(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      doctorId: map['doctorId'],
      enrolledStudentIds: List<String>.from(map['enrolledStudentIds'] ?? []),
    );
  }
}
