
import 'package:intl/intl.dart';
import 'package:halqati/test/printJson.dart';

class AssignmentClass{
  final int? id;
  final String? title;
  final String? description;
  final String? type;
  final String? dueDate;
  final String? assignedDate;
  final int? classId;
  final int? studentId;
  final List<int>? pages;
  final int? weekNumber;
  final bool? isCompleted;

  AssignmentClass({
    this.id,
    this.title,
    this.description,
    this.type,
    this.assignedDate,
    this.dueDate,
    this.classId,
    this.studentId,
    this.pages,
    this.weekNumber = 1,
    this.isCompleted = false
  });

  factory AssignmentClass.fromJson(Map<String, dynamic> json) {
    return AssignmentClass(
      id: json['id'] as int?,
      title: json['title'] as String?,
      description: json['description'] as String?,
      type: json['type'] as String?,
      assignedDate: json['assigned_date'] as String?,
      dueDate: json['due_date'] as String?,
      classId: json['class_id'] as int?,
      studentId: json['student_id'] as int?,
      isCompleted: json['is_completed'],
      pages: json['pages'] != null
          ? List<int>.from(json['pages'].map((x) => x as int))
          : null,
        weekNumber: json['week_number'] as int?,
    );
  }

  Map<String, dynamic> toJson() {

    String currentDate = DateFormat('yyyy-MM-dd').format(DateTime.now());

    return {
      'id': id,
      'title': title,
      'description': description,
      'type': type,
      'due_date': assignedDate,
      "assigned_date": currentDate,
      'class_id': classId,
      'student_id': studentId,
      'pages': pages,
      'week_number': weekNumber,
    };
  }

  AssignmentClass copyWith({
    int? id,
    String? title,
    String? description,
    String? type,
    String? assignedDate,
    String? dueDate,
    int? classId,
    int? studentId,
    List<int>? pages,
    int? weekNumber
  }) {
    return AssignmentClass(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      type: type ?? this.type,
      assignedDate: assignedDate ?? this.assignedDate,
      dueDate: dueDate ?? this.dueDate,
      classId: classId ?? this.classId,
      studentId: studentId ?? this.studentId,
      pages: pages ?? this.pages,
      weekNumber: weekNumber ?? this.weekNumber
    );
  }
}