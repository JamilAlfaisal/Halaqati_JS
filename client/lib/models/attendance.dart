import 'package:halqati/models/student.dart';

class Attendance {
  final String id;
  final DateTime date;
  final List<Student> students;

  Attendance({
    required this.id,
    required this.date,
    required this.students,
  });

  /// Creates a copy of this Attendance record with updated attributes
  Attendance copyWith({
    String? id,
    DateTime? date,
    List<Student>? students,
  }) {
    return Attendance(
      id: id ?? this.id,
      date: date ?? this.date,
      students: students ?? this.students,
    );
  }

  /// Factory constructor to create an Attendance instance from JSON
  factory Attendance.fromJson(Map<String, dynamic> json) {
    return Attendance(
      id: json['id'] as String,
      date: DateTime.parse(json['date']),
      students: (json['students'] as List)
          .map((studentJson) => Student.fromJson(studentJson))
          .toList(),
    );
  }

  /// Converts the Attendance instance into a Map (JSON)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'date': date.toIso8601String(),
      'students': students.map((student) => student.toJson()).toList(),
    };
  }
}