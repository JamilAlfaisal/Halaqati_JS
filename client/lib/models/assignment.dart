import 'package:easy_localization/easy_localization.dart';
import 'package:halqati/models/student.dart';
import 'package:halqati/models/teacher.dart';
import 'package:halqati/models/class_model.dart';
import 'package:halqati/utils/helper_methods.dart';

class AssignedStudents {
  final Student student;
  final bool isComplete;
  final bool isRead;

  const AssignedStudents({
    required this.isComplete,
    required this.student,
    required this.isRead
  });

  factory AssignedStudents.fromJson(Map<String, dynamic> json) {
    return AssignedStudents(
      student: Student.fromJson(json),
      isComplete: json['isComplete'] as bool? ?? false,
      isRead: json['isRead'] as bool
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'student': student.toJson(),
      'isComplete': isComplete,
      'isRead': isRead
    };
  }

  AssignedStudents copyWith({
    Student? student,
    bool? isComplete,
    bool? isRead,
  }) {
    return AssignedStudents(
      student: student ?? this.student,
      isComplete: isComplete ?? this.isComplete,
      isRead: isRead ?? this.isRead,
    );
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

  /// ✅ NEW
  final Teacher teacher;
  final ClassModel halaqaClass;

  Assignment({
    required this.id,
    required this.title,
    required this.dueDate,
    required this.type,
    required this.description,
    required this.pages,
    required this.createdDate,
    required this.students,

    /// ✅ NEW
    required this.teacher,
    required this.halaqaClass,
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

    /// ✅ NEW
    Teacher? teacher,
    ClassModel? halaqaClass,
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

      /// ✅ NEW
      teacher: teacher ?? this.teacher,
      halaqaClass: halaqaClass ?? this.halaqaClass,
    );
  }

  static String _getTerm(Map<String, dynamic> json, List<String> terms) {
    final String foundKey = terms.firstWhere(
          (term) => json[term] != null,
      orElse: () => "",
    );
    return foundKey;
  }

  /// 🔐 Safe date parser
  static DateTime _parseDate(dynamic value) {
    try {
      if (value == null || value.toString().isEmpty) {
        return DateTime(1970);
      }
      return DateTime.parse(value.toString());
    } catch (_) {
      return DateTime(1970);
    }
  }

  factory Assignment.fromJson(Map<String, dynamic> json) {

    /// ✅ Teacher handling
    Teacher teacher;
    if (json['teacher'] != null) {
      teacher = Teacher.fromJson(json['teacher']);
    } else {
      teacher = Teacher.emptyTeacher();
    }

    /// ✅ Class handling
    ClassModel halaqaClass;
    if (json['class'] != null) {
      halaqaClass = ClassModel.fromJson(json['class']);
    } else if (json['halaqaClass'] != null) {
      halaqaClass = ClassModel.fromJson(json['halaqaClass']);
    } else {
      halaqaClass = ClassModel.emptyClass();
    }

    return Assignment(
      id: HelperMethods.getTerms(json, ["id", "assignmentId"]),
      title: json['title'] ?? "undefined".tr(),
      dueDate: _parseDate(json['dueDate']),
      type: json['type'] ?? "Reading",
      description: json['description'] ?? "undefined".tr(),
      pages: List<String>.from(json['pages'] ?? []),
      createdDate: _parseDate(json['createdAt']),
      students: ((json[_getTerm(json, ["haveAssignment", "students"])] ?? [])
      as List)
          .map((s) => AssignedStudents.fromJson(s))
          .toList(),

      /// ✅ NEW
      teacher: teacher,
      halaqaClass: halaqaClass,
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

      /// ✅ NEW
      'teacher': teacher.toJson(),
      'class': halaqaClass.toJson(),
    };
  }

  static Assignment emptyAssignment(){
    return Assignment(
        id: '',
        title: '',
        dueDate: DateTime(2017, 9, 7, 17, 30),
        type: '',
        description: '',
        pages: [],
        createdDate: DateTime(2017, 9, 7, 17, 30),
        students: [],
        teacher: Teacher.emptyTeacher(),
        halaqaClass: ClassModel.emptyClass()
    );
  }
}