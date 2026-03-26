import 'package:halqati/models/assignment.dart';
import 'package:halqati/models/attendance.dart';
import 'package:halqati/models/event.dart';
import 'package:halqati/models/student.dart';
import 'package:halqati/test/printJson.dart';

class ClassModel {
  final String id; // Changed to int based on JSON
  final String teacherId; // Added teacherId
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
    required this.teacherId,
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

  /// Creates a copy of the class with updated attributes
  ClassModel copyWith({
    String? id,
    String? teacherId,
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
      teacherId: teacherId ?? this.teacherId,
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

  /// Factory constructor to create a ClassModel instance from JSON
  factory ClassModel.fromJson(Map<String, dynamic> json) {
    late String teacherId;
    if (json['teacherId'] != null){
      teacherId = json['teacherId'].toString();
    }else{
      teacherId = json['teacher']['id'].toString();
    }

    printJson(json, "class_model");
    return ClassModel(
      id: json['id'].toString(),
      teacherId: teacherId,
      name: json['name'] as String,
      description: json['description'] as String,
      location: json['location'] as String,
      startTime: json['startTime'] as String,
      endTime: json['endTime'] as String,
      days: List<String>.from(json['days']??[]),
      students: ((json['students']??[]) as List?)
          ?.map((s) => Student.fromJson(s))
          .toList() ?? [],
      events: ((json['events']??[]) as List?)
          ?.map((e) => Event.fromJson(e))
          .toList() ?? [],
      assignments: ((json['assignments']??[]) as List?)
          ?.map((a) => Assignment.fromJson(a))
          .toList() ?? [],
      attendanceRecords: ((json['attendances']??[]) as List?)
          ?.map((ar) => Attendance.fromJson(ar))
          .toList() ?? [],
    );
  }

  /// Converts the ClassModel instance into a Map (JSON)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'teacherId': teacherId,
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
    };
  }

  int studentCount() {
    return students.length;
  }
}