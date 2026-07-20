import 'grade_model.dart';

class StudentGradeReportModel {
  final double cumulativeGrade;
  final int totalWeightPoints;
  final DateTime? dateOfregistration;
  final List<GradeModel> history;

  StudentGradeReportModel({
    required this.cumulativeGrade,
    required this.totalWeightPoints,
    required this.dateOfregistration,
    required this.history,
  });

  void addMoreGrades (List<GradeModel> newHistory){
    history.addAll(newHistory);
  }

  factory StudentGradeReportModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) return StudentGradeReportModel.empty();

    final stats = json['overallStats'] as Map<String, dynamic>?;

    return StudentGradeReportModel(
      cumulativeGrade: double.tryParse(stats?['cumulativeGrade']?.toString() ?? '0.0') ?? 0.0,
      totalWeightPoints: int.tryParse(stats?['totalWeightPoints']?.toString() ?? '0') ?? 0,
      history: json['history'] is List
          ? (json['history'] as List)
          .map((gradeJson) => GradeModel.fromJson(gradeJson as Map<String, dynamic>))
          .toList()
          : [],
      dateOfregistration: json['dateOfregistration'] != null
          ? DateTime.parse(json['dateOfregistration'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'overallStats': {
        'cumulativeGrade': cumulativeGrade.toStringAsFixed(2),
        'totalWeightPoints': totalWeightPoints,
      },
      'history': history.map((grade) => grade.toJson()).toList(),
    };
  }

  static StudentGradeReportModel empty() {
    return StudentGradeReportModel(
      cumulativeGrade: 0.0,
      totalWeightPoints: 0,
      dateOfregistration: DateTime.now(),
      history: [],
    );
  }
}