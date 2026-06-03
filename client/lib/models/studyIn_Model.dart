import 'package:halqati/models/student.dart';

class StudyIn {
  final String registeredAt;
  final int id;
  final String cumulativeGrade;
  final int totalWeightPoints;
  final Student student;

  // Standard Constructor
  StudyIn({
    required this.registeredAt,
    required this.id,
    required this.cumulativeGrade,
    required this.totalWeightPoints,
    required this.student,
  });

  // 1. emptyStudyIn Factory Constructor
  factory StudyIn.emptyStudyIn() {
    return StudyIn(
      registeredAt: '',
      id: 0,
      cumulativeGrade: '0.0',
      totalWeightPoints: 0,
      student: Student.emptyStudent(),
    );
  }

  // 2. copyWith Method
  StudyIn copyWith({
    String? registeredAt,
    int? id,
    String? cumulativeGrade,
    int? totalWeightPoints,
    Student? student,
  }) {
    return StudyIn(
      registeredAt: registeredAt ?? this.registeredAt,
      id: id ?? this.id,
      cumulativeGrade: cumulativeGrade ?? this.cumulativeGrade,
      totalWeightPoints: totalWeightPoints ?? this.totalWeightPoints,
      student: student ?? this.student,
    );
  }

  // 3. fromJson Factory Constructor
  factory StudyIn.fromJson(Map<String, dynamic> json) {
    return StudyIn(
      registeredAt: json['registeredAt'] as String? ?? '',
      id: json['id'] as int? ?? 0,
      cumulativeGrade: json['cumulativeGrade'] as String? ?? '0.0',
      totalWeightPoints: json['totalWeightPoints'] as int? ?? 0,
      student: json['student'] != null
          ? Student.fromJson(json['student'] as Map<String, dynamic>)
          : Student.emptyStudent(),
    );
  }

  // 4. toJson Method
  Map<String, dynamic> toJson() {
    return {
      'registeredAt': registeredAt,
      'id': id,
      'cumulativeGrade': cumulativeGrade,
      'totalWeightPoints': totalWeightPoints,
      'student': student.toJson(),
    };
  }
}
