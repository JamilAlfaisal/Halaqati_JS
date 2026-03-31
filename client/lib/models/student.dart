



import 'package:easy_localization/easy_localization.dart';
import 'package:halqati/models/class_model.dart';
import 'package:halqati/models/user.dart';
import 'package:halqati/test/printJson.dart';
import 'package:halqati/utils/helper_methods.dart';

class Student extends User {
  final List<String> memorizedJuz;
  final List<ClassModel> enrolledClasses;

  Student({
    required String id,
    required String name,
    required String email,
    required String role,
    required DateTime dob,
    required DateTime createdAt,
    required String picProfile,
    required String phone,
    required this.memorizedJuz,
    required this.enrolledClasses,
  }):super(
      id: id,
      name: name,
      email: email,
      phone: phone,
      role: role,
      dob: dob,
      createdAt: createdAt,
      picProfile: picProfile,
    );

  // The copyWith method for immutability
  Student copyWith({
    String? id,
    String? name,
    String? phone,
    String? email,
    String? role,
    DateTime? dob,
    DateTime? createdAt,
    String? picProfile,
    List<String>? memorizedJuz,
    List<ClassModel>? enrolledClasses,
  }) {
    return Student(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      role: role ?? this.role,
      phone: phone ?? this.phone,
      dob: dob ?? this.dob,
      createdAt: createdAt ?? this.createdAt,
      picProfile: picProfile ?? this.picProfile,
      memorizedJuz: memorizedJuz ?? this.memorizedJuz,
      enrolledClasses: enrolledClasses ?? this.enrolledClasses,
    );
  }

  factory Student.fromJson(Map<String, dynamic> json) {
    printJson(json, "this is the students");
    return Student(
      id: HelperMethods.getTerms(json, ["id", "studentId"]),
      name: json['name'] as String? ?? "undefined".tr(),
      email: json['email'] as String? ?? "undefined".tr(),
      role: json['role'] as String? ?? "student",
      picProfile: json['picProfile'] as String? ?? "undefined".tr(),
      phone: json['phone']?.toString() ?? "undefined".tr(),
      dob: DateTime.tryParse(json['dob'] ?? "") ?? DateTime.now(),
      createdAt: DateTime.tryParse(json['createdAt'] ?? "undefined".tr()) ?? DateTime.now(),
      memorizedJuz: json['memorizedJuz'] != null
          ? List<String>.from(json['memorizedJuz'])
          : [],
      enrolledClasses: (json['enrolledClasses'] as List?)
          ?.map((e) => ClassModel.fromJson(e as Map<String, dynamic>))
          .toList() ?? [],
    );
  }

  // Method to convert Student instance to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'role': role,
      'phone':phone,
      'dob': dob.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'picProfile': picProfile,
      'scores': memorizedJuz,
      'enrolledClasses': enrolledClasses.map((e) => e.toJson()).toList(),
    };
  }
}