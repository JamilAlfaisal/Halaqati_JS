import 'package:easy_localization/easy_localization.dart';
import 'package:halqati/models/assignment.dart';
import 'package:halqati/models/attendance.dart';
import 'package:halqati/models/event.dart';
import 'package:halqati/models/student.dart';
import 'package:halqati/test/printJson.dart';
import 'package:halqati/models/teacher.dart';

class ClassModel {
  final String id;
  final Teacher teacher; // ✅ replaced teacherId
  final String name;
  final String description;
  final String location;
  final String startTime;
  final String endTime;
  final List<String> days;
  final List<Student> students;
  final List<Event> events;
  final List<Assignment> assignments;
  final List<Attendance> attendanceRecords;

  ClassModel({
    required this.id,
    required this.teacher,
    required this.name,
    required this.description,
    required this.location,
    required this.startTime,
    required this.endTime,
    required this.days,
    required this.students,
    required this.events,
    required this.assignments,
    required this.attendanceRecords,
  });

  /// CopyWith
  ClassModel copyWith({
    String? id,
    Teacher? teacher,
    String? name,
    String? description,
    String? location,
    String? startTime,
    String? endTime,
    List<String>? days,
    List<Student>? students,
    List<Event>? events,
    List<Assignment>? assignments,
    List<Attendance>? attendanceRecords,
  }) {
    return ClassModel(
      id: id ?? this.id,
      teacher: teacher ?? this.teacher,
      name: name ?? this.name,
      description: description ?? this.description,
      location: location ?? this.location,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      days: days ?? this.days,
      students: students ?? this.students,
      events: events ?? this.events,
      assignments: assignments ?? this.assignments,
      attendanceRecords: attendanceRecords ?? this.attendanceRecords,
    );
  }

  /// Factory
  factory ClassModel.fromJson(Map<String, dynamic> json) {
    printJson(json, "class_model");

    /// ✅ Handle teacher safely
    Teacher teacher;

    if (json['teacher'] != null) {
      teacher = Teacher.fromJson(json['teacher']);
    } else if (json['teacherId'] != null) {
      // fallback if backend only sends ID
      teacher = Teacher(
        id: json['teacherId'].toString(),
        name: "undefined".tr(),
        email: "undefined".tr(),
        phone: "undefined".tr(), role: 'teacher', dob: DateTime.now(), createdAt: DateTime.now(), picProfile: '', createdClasses: [],
      );
    } else {
      // fallback empty teacher
      teacher = Teacher(
        id: "0",
        name: "undefined".tr(),
        email: "undefined".tr(),
        phone: "undefined".tr(), role: 'Teacher', dob: DateTime.now(), createdAt: DateTime.now(), picProfile: '', createdClasses: [],
      );
    }

    return ClassModel(
      id: json['id']?.toString() ?? "0",
      teacher: teacher,
      name: json['name'] ?? "undefined".tr(),
      description: json['description'] ?? "undefined".tr(),
      location: json['location'] ?? "undefined".tr(),
      startTime: json['startTime'] ?? "undefined".tr(),
      endTime: json['endTime'] ?? "undefined".tr(),
      days: List<String>.from(json['days'] ?? []),

      students: ((json['students'] ?? []) as List)
          .map((s) => Student.fromJson(s))
          .toList(),

      events: ((json['events'] ?? []) as List)
          .map((e) => Event.fromJson(e))
          .toList(),

      assignments: ((json['assignments'] ?? []) as List)
          .map((a) => Assignment.fromJson(a))
          .toList(),

      attendanceRecords: ((json['attendances'] ?? []) as List)
          .map((ar) => Attendance.fromJson(ar))
          .toList(),
    );
  }

  /// To JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'teacher': teacher.toJson(), // ✅ full object
      'name': name,
      'description': description,
      'location': location,
      'startTime': startTime,
      'endTime': endTime,
      'days': days,
      'students': students.map((s) => s.toJson()).toList(),
      'events': events.map((e) => e.toJson()).toList(),
      'assignments': assignments.map((a) => a.toJson()).toList(),
      'attendances':
      attendanceRecords.map((ar) => ar.toJson()).toList(),
    };
  }

  int studentCount() {
    return students.length;
  }

  static ClassModel emptyClass (){
      return ClassModel(
        id: "",
        teacher:  Teacher.emptyTeacher(),
        name: "",
        description: "",
        location: "",
        startTime: "",
        endTime: "",
        days: const [],
        students: const [],
        events: const [],
        assignments: const [],
        attendanceRecords: const [],
      );
  }
}