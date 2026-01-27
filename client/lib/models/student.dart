import 'package:halqati/models/teacher.dart';
import 'package:halqati/models/assignment_class.dart';
import 'package:halqati/models/halaqa_class.dart';
import 'package:halqati/test/printJson.dart';

class Student{
  final int? id;
  final String? name;
  final String? email;
  final String? phone;
  final String? dateOfBirth;
  final int? classId;
  final List<bool>? memorizedPages;
  final Teacher? teacher;
  final HalaqaClass? halaqaClass;
  final List<AssignmentClass>? assignmentClass;

  // final int? studentCount;

  Student({
    this.id,
    this.name,
    this.phone,
    this.email,
    this.dateOfBirth,
    this.classId,
    this.memorizedPages,
    this.halaqaClass,
    this.assignmentClass,
    this.teacher
    // this.studentCount
  });

static Map<String, dynamic> findAliases(Map<String, dynamic>? json, List<String> aliases){
  for (var key in aliases){
    if(json != null && json[key] != null){
      return json[key];
    }
  }
  return {};
}

  factory Student.fromJson(Map<String, dynamic> json) {
    // print('student id: ${json}');
    final data = findAliases(json, ['student', 'students']);
    printJson(json, 'student class fromJson');
    late final Teacher teacher;
    late final HalaqaClass halaqaClass;
    late final List<AssignmentClass>? assignmentClass;

    if (data["teacher"] != null && data["teacher"]['user'] != null){
      teacher = Teacher.fromJson(data["teacher"]["user"]);
    }else{
      teacher =  Teacher();
    }

    if (data["class"] != null){
      halaqaClass = HalaqaClass.fromJson(data["class"]);
    }else{
      halaqaClass = HalaqaClass(id: 0,name: '');
    }

    if (json['recent_progress'] != null){
      assignmentClass = List<AssignmentClass>.from(json['recent_progress'].map((x)=>AssignmentClass.fromJson(
          {...x['assignment'],"is_completed":x['is_completed']})));
    }else{
      assignmentClass = [];
    }
    return Student(
      id: data['id'] as int?,
      name: data['name'] as String?,
      email: data['email'] as String?,
      phone: data['phone'] as String?,
      dateOfBirth: data['date_of_birth'] as String?,
      classId: data['class_id'] as int?,
      memorizedPages: data['memorized_pages'] != null
        ? List<bool>.from(data['memorized_pages'].map((x) => x as bool))
        : null,
      teacher: teacher,
      halaqaClass: halaqaClass,
      assignmentClass: assignmentClass,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'date_of_birth': dateOfBirth,
      'class_id': classId,
      'memorized_pages': memorizedPages,
    };
  }

  Student copyWith({
    int? id,
    String? name,
    String? email,
    String? phone,
    String? dateOfBirth,
    int? classId,
    List<bool>? memorizedPages,
  }) {
    return Student(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      classId: classId ?? this.classId,
      memorizedPages: memorizedPages ?? this.memorizedPages,
    );
  }
}