



import 'package:halqati/models/class_model.dart';
import 'package:halqati/models/user.dart';

class Teacher extends User {
  final List<ClassModel> createdClasses;

  Teacher({
    required super.id,
    required super.name,
    required super.phone,
    required super.email,
    required super.role,
    required super.dob,
    required super.createdAt,
    required super.picProfile,
    required this.createdClasses,
  });

  Teacher copyWith({
    String? id,
    String? name,
    String? email,
    String? role,
    DateTime? dob,
    DateTime? createdAt,
    String? phone,
    String? picProfile,
    List<ClassModel>? createdClasses,
  }) =>
      Teacher(
        id: id ?? this.id,
        name: name ?? this.name,
        phone: phone ?? this.phone,
        email: email ?? this.email,
        role: role ?? this.role,
        dob: dob ?? this.dob,
        createdAt: createdAt ?? this.createdAt,
        picProfile: picProfile ?? this.picProfile,
        createdClasses: createdClasses ?? this.createdClasses,
      );

  factory Teacher.fromJson(Map<String, dynamic> json) {
    final List <ClassModel> classes = ((json['createdClasses'] ?? []) as List)
      .map((e) => ClassModel.fromJson(e)).toList();
    return Teacher(
      id: json['id'].toString(),
      name: json['name'],
      email: json['email'],
      role: json['role'],
      phone: json['phone'],
      dob: DateTime.parse(json['dob']),
      createdAt: DateTime.parse(json['createdAt']),
      picProfile: json['picProfile']??"",
      createdClasses: classes,
      );
  }

  Map<String, dynamic> toJson() =>
      {
        'id': id,
        'name': name,
        'email': email,
        'role': role,
        'dob': dob.toIso8601String(),
        'createdAt': createdAt.toIso8601String(),
        'picProfile': picProfile,
        'createdClasses': createdClasses.map((e) => e.toJson()).toList(),
      };
}