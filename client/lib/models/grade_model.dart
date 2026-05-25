import 'package:halqati/models/teacher.dart';
import 'package:halqati/models/assignment.dart';

class GradeModel {
  final String id;
  final double score;
  final int weight;
  final String? description;
  final DateTime dateTime;
  final Teacher? teacher;
  final Assignment? assignment;

  GradeModel({
    required this.id,
    required this.score,
    required this.weight,
    this.description,
    required this.dateTime,
    this.teacher,
    this.assignment,
  });

  factory GradeModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) return GradeModel.empty();

    return GradeModel(
      id: json['id'] as String? ?? '',
      score: double.tryParse(json['score']?.toString() ?? '0.0') ?? 0.0,
      weight: json['weight'] as int? ?? 1,
      description: json['description'] as String?,
      dateTime: json['dateTime'] != null
          ? DateTime.parse(json['dateTime'] as String)
          : DateTime.now(),
      teacher: json['teacher'] != null
          ? Teacher.fromJson(json['teacher'] as Map<String, dynamic>)
          : null,
      assignment: json['assignment'] != null
          ? Assignment.fromJson(json['assignment'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'score': score.toStringAsFixed(2), // Send back as string for DB consistency
      'weight': weight,
      'description': description,
      'dateTime': dateTime.toIso8601String(),
      'teacher': teacher?.toJson(),
      'assignment': assignment?.toJson(),
    };
  }

  static GradeModel empty() {
    return GradeModel(
      id: '',
      score: 0.0,
      weight: 1,
      description: null,
      dateTime: DateTime.now(),
      teacher: Teacher.emptyTeacher(),
      assignment: null, // Or AssignmentModel.empty() if created
    );
  }

  GradeModel copyWith({
    String? id,
    double? score,
    int? weight,
    String? description,
    DateTime? dateTime,
    Teacher? teacher,
    Assignment? assignment,
  }) {
    return GradeModel(
      id: id ?? this.id,
      score: score ?? this.score,
      weight: weight ?? this.weight,
      description: description ?? this.description,
      dateTime: dateTime ?? this.dateTime,
      teacher: teacher ?? this.teacher,
      assignment: assignment ?? this.assignment,
    );
  }

}