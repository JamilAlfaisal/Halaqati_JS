import 'package:easy_localization/easy_localization.dart';
import 'package:halqati/models/assignment.dart';
import 'package:halqati/models/attendance.dart';
import 'package:halqati/models/event.dart';
import 'package:halqati/models/student.dart';
import 'package:halqati/models/studyIn_Model.dart';
import 'package:halqati/test/printJson.dart';
import 'package:halqati/models/teacher.dart';

class ClassModel {
  final String id;
  final Teacher teacher;
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
  final List<StudyIn> studyIn;

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
    required this.studyIn,
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
    List<StudyIn>? studyIn,
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
      studyIn: studyIn ?? this.studyIn,
    );
  }

  /// Factory with Strict Null & Type-Cast Safety
  factory ClassModel.fromJson(Map<String, dynamic>? json) {
    // If the entire class JSON object is null, return a fresh empty instance
    if (json == null) return ClassModel.emptyClass();

    /// ✅ Handle teacher safely
    Teacher teacher;
    if (json['teacher'] != null && json['teacher'] is Map<String, dynamic>) {
      teacher = Teacher.fromJson(json['teacher'] as Map<String, dynamic>);
    } else if (json['teacherId'] != null) {
      teacher = Teacher.emptyTeacher().copyWith(id: json['teacherId'].toString());
    } else {
      teacher = Teacher.emptyTeacher();
    }

    return ClassModel(
      id: json['id']?.toString() ?? "0",
      teacher: teacher,
      name: json['name'] as String? ?? "undefined".tr(),
      description: json['description'] as String? ?? "undefined".tr(),
      location: json['location'] as String? ?? "undefined".tr(),
      startTime: json['startTime'] as String? ?? "undefined".tr(),
      endTime: json['endTime'] as String? ?? "undefined".tr(),

      // Safe fallback for days array
      days: json['days'] is List
          ? List<String>.from(json['days'] as List)
          : const [],

      // Safe mapped parser for students array
      students: json['students'] is List
          ? (json['students'] as List)
          .where((s) => s != null && s is Map<String, dynamic>)
          .map((s) => Student.fromJson(s as Map<String, dynamic>))
          .toList()
          : const [],

      // Safe mapped parser for events array
      events: json['events'] is List
          ? (json['events'] as List)
          .where((e) => e != null && e is Map<String, dynamic>)
          .map((e) => Event.fromJson(e as Map<String, dynamic>))
          .toList()
          : const [],

      // Safe mapped parser for assignments array
      assignments: json['assignments'] is List
          ? (json['assignments'] as List)
          .where((a) => a != null && a is Map<String, dynamic>)
          .map((a) => Assignment.fromJson(a as Map<String, dynamic>))
          .toList()
          : const [],

      // Safe mapped parser for attendances array
      attendanceRecords: json['attendances'] is List
          ? (json['attendances'] as List)
          .where((ar) => ar != null && ar is Map<String, dynamic>)
          .map((ar) => Attendance.fromJson(ar as Map<String, dynamic>))
          .toList()
          : const [],

      // Safe mapped parser for studyIn array
      studyIn: json['studyIn'] is List
          ? (json['studyIn'] as List)
          .where((si) => si != null && si is Map<String, dynamic>)
          .map((si) => StudyIn.fromJson(si as Map<String, dynamic>))
          .toList()
          : const [],
    );
  }

  /// To JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'teacher': teacher.toJson(),
      'name': name,
      'description': description,
      'location': location,
      'startTime': startTime,
      'endTime': endTime,
      'days': days,
      'students': students.map((s) => s.toJson()).toList(),
      'events': events.map((e) => e.toJson()).toList(),
      'assignments': assignments.map((a) => a.toJson()).toList(),
      'attendances': attendanceRecords.map((ar) => ar.toJson()).toList(),
      'studyIn': studyIn.map((si) => si.toJson()).toList(),
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
      studyIn: const [],
    );
  }
}