import 'package:easy_localization/easy_localization.dart';
import 'package:halqati/models/teacher.dart';
import 'package:halqati/models/class_model.dart';
import 'package:halqati/test/printJson.dart';
import 'package:halqati/utils/helper_methods.dart';

class Event {
  final String id;
  final String title;
  final String description;
  final DateTime createdDate;
  final DateTime dueDate;

  /// ✅ NEW
  final Teacher teacher;
  final ClassModel halaqaClass;

  Event({
    required this.id,
    required this.title,
    required this.description,
    required this.createdDate,
    required this.dueDate,

    /// ✅ NEW
    required this.teacher,
    required this.halaqaClass,
  });

  Event copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? createdDate,
    DateTime? dueDate,

    /// ✅ NEW
    Teacher? teacher,
    ClassModel? halaqaClass,
  }) {
    return Event(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      createdDate: createdDate ?? this.createdDate,
      dueDate: dueDate ?? this.dueDate,

      /// ✅ NEW
      teacher: teacher ?? this.teacher,
      halaqaClass: halaqaClass ?? this.halaqaClass,
    );
  }

  /// 🔐 Safe Date Parser
  static DateTime _safeParseDate(dynamic dateValue) {
    if (dateValue == null || dateValue.toString().isEmpty) {
      return DateTime(1970);
    }
    try {
      return DateTime.parse(dateValue.toString());
    } catch (_) {
      return DateTime(1970);
    }
  }

  factory Event.fromJson(Map<String, dynamic> json) {

    /// ✅ Teacher handling
    Teacher teacher;
    if (json['teacher'] != null) {
      teacher = Teacher.fromJson(json['teacher']);
    } else {
      teacher = Teacher(
        id: "0",
        name: "undefined".tr(),
        email: "undefined".tr(),
        phone: "undefined".tr(), role: 'teacher', dob: DateTime.now(), createdAt: DateTime.now(), picProfile: '', createdClasses: [],
      );
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

    return Event(
      id: HelperMethods.getTerms(json, ["id", "eventId"]).toString(),
      title: (json['title'] ?? 'No Title').toString(),
      description: (json['description'] ?? "undefined".tr()).toString(),
      createdDate:
      _safeParseDate(json['createdAt'] ?? json['createdDate']),
      dueDate: _safeParseDate(json['dueDate']),

      /// ✅ NEW
      teacher: teacher,
      halaqaClass: halaqaClass,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'createdAt': createdDate.toIso8601String(),
      'dueDate': dueDate.toIso8601String(),

      /// ✅ NEW
      'teacher': teacher.toJson(),
      'class': halaqaClass.toJson(),
    };
  }
}