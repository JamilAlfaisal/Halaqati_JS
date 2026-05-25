import 'package:halqati/models/student.dart';
import 'package:halqati/test/printJson.dart';
import 'package:halqati/utils/helper_methods.dart';

class Attendance {
  final String id;
  final DateTime date;
  final List<Student> students;

  Attendance({
    required this.id,
    required this.date,
    required this.students,
  });

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

  factory Attendance.fromJson(Map<String, dynamic> json) {
    return Attendance(
      id: HelperMethods.getTerms(json, ["id", "attendanceId"]).toString(),
      date: DateTime.parse(json['date']),
      students: ((json['students']??[]) as List)
          .map((studentJson) => Student.fromJson(studentJson))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'date': date.toIso8601String(),
      'students': students.map((student) => student.toJson()).toList(),
    };
  }
}