import 'package:halqati/models/student.dart';
import 'package:halqati/test/printJson.dart';
import 'package:halqati/utils/helper_methods.dart';

class AssignedStudents {
  final Student student;
  final bool isComplete;

  const AssignedStudents({
    required this.isComplete,
    required this.student,
  });

  factory AssignedStudents.fromJson(Map<String, dynamic> json) {
    return AssignedStudents(
      student: Student.fromJson(json),
      isComplete: json['isComplete'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'student': student.toJson(),
      'isComplete': isComplete,
    };
  }
}

class Assignment {
  final String id;
  final String title;
  final DateTime dueDate;
  final String type;
  final String description;
  final List<String> pages;
  final DateTime createdDate;
  final List<AssignedStudents> students;

  Assignment({
    required this.id,
    required this.title,
    required this.dueDate,
    required this.type,
    required this.description,
    required this.pages,
    required this.createdDate,
    required this.students,
  });

  Assignment copyWith({
    String? id,
    String? title,
    DateTime? dueDate,
    String? type,
    String? description,
    List<String>? pages,
    DateTime? createdDate,
    List<AssignedStudents>? students,
  }) {
    return Assignment(
      id: id ?? this.id,
      title: title ?? this.title,
      dueDate: dueDate ?? this.dueDate,
      type: type ?? this.type,
      description: description ?? this.description,
      pages: pages ?? this.pages,
      createdDate: createdDate ?? this.createdDate,
      students: students ?? this.students,
    );
  }

  static String _getTerm(Map<String, dynamic> json, List<String> terms) {
    final String foundKey = terms.firstWhere(
          (term) => json[term] != null,
      orElse: () => "",
    );
    return foundKey;
  }

  /// Factory constructor to create an Assignment from JSON
  factory Assignment.fromJson(Map<String, dynamic> json) {
    print("id: ${HelperMethods.getTerms(json, ["id", "assignmentId"])}");

    printJson(json, "assignmentModel");
    print("after printJson");
    return Assignment(
      id: HelperMethods.getTerms(json, ["id", "assignmentId"]),
      title: json['title'] ??"",
      dueDate: DateTime.parse(json['dueDate']??""),
      type: json['type']??"",
      description: json['description']??"",
      pages: List<String>.from(json['pages']??[]),
      createdDate: DateTime.parse(json['createdAt']??""),
      students: [],
      // students:  (json[_getTerm(json, ["haveAssignment", "students"]) ] as List)
      //     .map((s) => AssignedStudents.fromJson(s))
      //     .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'dueDate': dueDate.toIso8601String(),
      'type': type,
      'description': description,
      'pages': pages,
      'createdDate': createdDate.toIso8601String(),
      'students': students.map((s) => s.toJson()).toList(),
    };
  }
}