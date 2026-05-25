import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:halqati/core/exceptions/api_exceptions.dart';
import 'package:halqati/core/utils/auth_utils.dart';
import 'package:halqati/models/FeedItem.dart';
import 'package:halqati/models/assignment.dart';
import 'package:halqati/models/event.dart';
import 'package:halqati/provider/is_loading_more_provider.dart';
import 'package:halqati/provider/services_providers/event_api_provider.dart';
import 'package:halqati/provider/student_providers/selected_feed_provider.dart';
import 'package:halqati/provider/token_notifier.dart';

final feedProvider =
AsyncNotifierProvider<FeedNotifier, List<FeedItem>?>(FeedNotifier.new);

class FeedNotifier extends AsyncNotifier<List<FeedItem>?> {
  int _offset = 0;
  final int _limit = 10;
  bool _hasMore = true;

  bool get hasMore => _hasMore;

  @override
  Future<List<FeedItem>?> build() async {
    ref.keepAlive();
    _offset = 0;
    _hasMore = true;
    return await _fetch(reset: true);
  }

  Future<List<FeedItem>?> _fetch({bool reset = false}) async {
    final token = ref.read(tokenProvider).value;

    if (token == null || token.isEmpty) return [];

    try {
      final data = await ref.read(eventApiProvider).getFeed(
        token,
        offset: _offset,
        limit: _limit,
      );

      if (reset) {
        _offset = data.length;
        _hasMore = data.length == _limit;
        return data;
      } else {
        _offset += data.length;

        if (data.length < _limit) {
          _hasMore = false;
        }

        return [...?state.value, ...data];
      }
    } catch (e) {
      if (e is UnauthorizedException) {
        await AuthHelper.handleLogout(ref);
      }
      rethrow;
    }
  }

  Future<void> loadMore() async {
    final loadingProvider = isLoadingMoreProvider("feed");

    if (!_hasMore || ref.read(loadingProvider)) return;

    ref.read(loadingProvider.notifier).state = true;

    try {
      final newData = await _fetch();
      state = AsyncData(newData);
    } catch (e, stack) {
      state = AsyncError(e, stack);
    } finally {
      ref.read(loadingProvider.notifier).state = false;
    }
  }

  FeedItem? getSelectedItem() {

    final selected = ref.read(selectedFeedItemProvider);

    if (!state.hasValue || state.value == null || selected == null) {
      return null;
    }

    try {
      return state.value!.firstWhere(
            (item) {
          if (selected.type == FeedType.assignment &&
              item.type == FeedType.assignment) {
            final assignment = item.data as Assignment;
            return assignment.id == selected.id;
          }

          if (selected.type == FeedType.event &&
              item.type == FeedType.event) {
            final event = item.data as Event;
            return event.id == selected.id;
          }

          return false;
        },
      );
    } catch (_) {
      return null;
    }
  }

  void markAsRead(int assignmentId, int studentId) {
    state = state.whenData((items) {
      if (items == null) return [];

      return items.map((feedItem) {
        if (feedItem.type == FeedType.assignment) {
          final Assignment assignment = feedItem.data;

          if (assignment.id.toString() != assignmentId.toString()) {
            return feedItem;
          }

          final updatedStudent =
          assignment.students[0].copyWith(isRead: true);

          final updatedAssignment = assignment.copyWith(
            students: [updatedStudent],
          );

          return FeedItem(
            type: FeedType.assignment,
            createdAt: feedItem.createdAt,
            data: updatedAssignment,
          );
        }
        return feedItem;
      }).toList();
    });
  }

  void markAsCompleted(String assignmentId) {
    state = state.whenData((items) {
      if (items == null) return [];

      return items.map((feedItem) {
        // ✅ Only update assignments
        if (feedItem.type == FeedType.assignment) {
          final assignment = feedItem.data as Assignment;

          if (assignment.id != assignmentId.toString()) {
            return feedItem;
          }

          // 🔥 Update ALL students OR first student (based on your logic)
          final updatedStudents = assignment.students.map((student) {
            return student.copyWith(isComplete: true);
          }).toList();

          final updatedAssignment = assignment.copyWith(
            students: updatedStudents,
          );

          // 🔥 Return updated FeedItem
          return FeedItem(
            type: FeedType.assignment,
            createdAt: feedItem.createdAt,
            data: updatedAssignment,
          );
        }

        return feedItem;
      }).toList();
    });
  }

}