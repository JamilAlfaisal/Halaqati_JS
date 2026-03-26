import 'package:halqati/test/printJson.dart';
import 'package:halqati/utils/helper_methods.dart';

class Event {
  final String id;
  final String title;
  final String description;
  final DateTime createdDate;
  final DateTime dueDate;

  Event({
    required this.id,
    required this.title,
    required this.description,
    required this.createdDate,
    required this.dueDate,
  });

  Event copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? createdDate,
    DateTime? dueDate,
  }) {
    return Event(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      createdDate: createdDate ?? this.createdDate,
      dueDate: dueDate ?? this.dueDate,
    );
  }

  factory Event.fromJson(Map<String, dynamic> json) {
    DateTime safeParseDate(dynamic dateValue) {
      if (dateValue == null) return DateTime.now();
      try {
        return DateTime.parse(dateValue.toString());
      } catch (e) {
        return DateTime.now();
      }
    }
    return Event(
      id: HelperMethods.getTerms(json, ["id", "eventId"]).toString(),
      title: (json['title'] ?? 'No Title').toString(),
      description: (json['description'] ?? '').toString(),
      createdDate: safeParseDate(json['createdAt'] ?? json['createdDate']),
      dueDate: safeParseDate(json['dueDate']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'createdAt': createdDate.toIso8601String(),
      'dueDate': dueDate.toIso8601String(),
    };
  }
}