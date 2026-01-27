import 'package:halqati/models/student.dart';
import 'package:halqati/test/printJson.dart';


class HalaqaClass {
  final int? id;
  final String? name;
  final String? description;
  final int? capacity;
  final String? roomNumber;
  final List<String>?  days;
  final String? time;
  final List<Student>? students;
  final int? teacherId;

  HalaqaClass({
    required this.id,
    required this.name,
    this.description,
    this.capacity,
    this.days,
    this.roomNumber,
    this.students,
    this.time,
    this.teacherId
  });

  factory HalaqaClass.fromJson(Map<String, dynamic> json) {
    printJson(json['students'], 'halaqa_class from json');
    print('id ${json['id']}');
    // print(json['name']);
    // print(json['description']);
    // print(json['capacity']);
    // print(json['room_number']);
    // print(json['schedule']['time']);
    // print(json['schedule']['days']);
    // print(json['teacher_id']);
    return HalaqaClass(
      id: json['id'] as int?,
      name: json['name'] as String?,
      description: json['description'] as String?,
      capacity: json['capacity'] as int?,
      roomNumber: json['room_number'] as String?,
      time: json['schedule']['time'] as String?,
        teacherId: json['teacher_id'] as int?,
      days: json['schedule']['days'] != null
          ? (json['schedule']['days'] as List)
          .map((item) => item.toString())
          .toList() // This converts the Iterable back into a List<String>
          : [],
      // students: [],
      students: json['students'] != null
          ? List<Student>.from(
          (json['students'] as List).map((x) => Student.fromJson({'students':x})))
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'capacity': capacity,
      'room_number': roomNumber,
      'time': time,
      'days': days,
      'students': students?.map((x) => x.toJson()).toList(),
    };
  }

  HalaqaClass copyWith({
    int? id,
    String? name,
    String? description,
    int? capacity,
    String? roomNumber,
    List<String>? days,
    String? time,
    List<Student>? students,
  }) {
    return HalaqaClass(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      capacity: capacity ?? this.capacity,
      roomNumber: roomNumber ?? this.roomNumber,
      days: days ?? this.days,
      time: time ?? this.time,
      students: students ?? this.students,
    );
  }

  int get studentCount => students?.length ?? 0;

  bool get isFull => capacity != null && studentCount >= capacity!;

  String get daysString => days?.join(', ') ?? 'No days specified';

}