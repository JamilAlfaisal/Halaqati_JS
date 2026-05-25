import "package:halqati/models/page_model.dart";

class JuzModel {
  final int chapter;
  final int startPage;
  final int endPage;
  final int totalPages;
  final int memorizedCount;
  final List<PageProgressModel> memorizedPages;

  JuzModel({
    required this.chapter,
    required this.startPage,
    required this.endPage,
    required this.totalPages,
    required this.memorizedCount,
    required this.memorizedPages,
  });

  factory JuzModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) return JuzModel.empty();

    return JuzModel(
      chapter: json['chapter'] as int? ?? 0,
      startPage: json['startPage'] as int? ?? 0,
      endPage: json['endPage'] as int? ?? 0,
      totalPages: json['totalPages'] as int? ?? 0,
      memorizedCount: json['memorizedCount'] as int? ?? 0,
      // Safely handle if 'memorizedPages' is null or not a list
      memorizedPages: json['memorizedPages'] is List
          ? (json['memorizedPages'] as List)
          .map((pageJson) => PageProgressModel.fromJson(pageJson as Map<String, dynamic>))
          .toList()
          : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'chapter': chapter,
      'startPage': startPage,
      'endPage': endPage,
      'totalPages': totalPages,
      'memorizedCount': memorizedCount,
      'memorizedPages': memorizedPages.map((page) => page.toJson()).toList(),
    };
  }

  static JuzModel empty() {
    return JuzModel(
      chapter: 0,
      startPage: 0,
      endPage: 0,
      totalPages: 0,
      memorizedCount: 0,
      memorizedPages: [],
    );
  }

  JuzModel copyWith({List<PageProgressModel>? memorizedPages, int? memorizedCount}) {
    return JuzModel(
      chapter: chapter,
      startPage: startPage,
      endPage: endPage,
      totalPages: totalPages,
      memorizedCount: memorizedCount ?? this.memorizedCount,
      memorizedPages: memorizedPages ?? this.memorizedPages,
    );
  }
}
