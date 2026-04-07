import 'package:halqati/models/assignment.dart';
import 'package:halqati/models/event.dart';

enum FeedType { assignment, event }

class FeedItem {
  final FeedType type;
  final DateTime createdAt;
  final dynamic data;

  FeedItem({
    required this.type,
    required this.createdAt,
    required this.data,
  });

  factory FeedItem.fromJson(Map<String, dynamic> json) {
    final type = json['type'];
    if (type == "assignment") {
      return FeedItem(
        type: FeedType.assignment,
        createdAt: DateTime.parse(json['createdAt']),
        data: Assignment.fromJson(json['data']),
      );
    } else {
      return FeedItem(
        type: FeedType.event,
        createdAt: DateTime.parse(json['createdAt']),
        data: Event.fromJson(json['data']),
      );
    }
  }
}

class SelectedFeedItem {
  final String id;
  final FeedType type;

  SelectedFeedItem({
    required this.id,
    required this.type,
  });
}