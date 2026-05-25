import "package:halqati/models/class_model.dart";
import "package:halqati/models/teacher.dart";

class PageProgressModel {
  final String id;
  final int pageNumber;
  final DateTime markingDate;
  final DateTime? reviewDate;
  final Teacher? teacher;
  final ClassModel? classData;

  PageProgressModel({
    required this.id,
    required this.pageNumber,
    required this.markingDate,
    this.reviewDate,
    this.teacher,
    this.classData,
  });

  factory PageProgressModel.fromJson(Map<String, dynamic> json) {
    return PageProgressModel(
      id: json['id'] as String,
      pageNumber: json['pageNumber'] as int,
      markingDate: DateTime.parse(json['markingDate'] as String),
      reviewDate: json['reviewDate'] != null
          ? DateTime.parse(json['reviewDate'] as String)
          : null,
      teacher: json['teacher'] != null
          ? Teacher.fromJson(json['teacher'] as Map<String, dynamic>)
          : null,
      classData: json['class'] != null
          ? ClassModel.fromJson(json['class'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'pageNumber': pageNumber,
      'markingDate': markingDate.toIso8601String(),
      'reviewDate': reviewDate?.toIso8601String(),
      'teacher': teacher?.toJson(),
      'class': classData?.toJson(),
    };
  }

  static PageProgressModel empty() {
    return PageProgressModel(
      id: '',
      pageNumber: 0,
      markingDate: DateTime.now(),
      reviewDate: null,
      teacher: Teacher.emptyTeacher(),
      classData: ClassModel.emptyClass(),
    );
  }

  PageProgressModel copyWith({DateTime? reviewDate}) {
    return PageProgressModel(
      id: id, pageNumber: pageNumber, markingDate: markingDate,
      reviewDate: reviewDate ?? this.reviewDate,
      teacher: teacher, classData: classData,
    );
  }
}