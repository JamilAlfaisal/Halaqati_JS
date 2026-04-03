import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:halqati/core/exceptions/api_exceptions.dart';
import 'package:halqati/core/utils/auth_utils.dart';
import 'package:halqati/models/assignment.dart';
import 'package:halqati/models/event.dart';
// import 'package:halqati/provider/api_service_provider.dart';
import 'package:halqati/provider/services_providers/event_api_provider.dart';
import 'package:halqati/provider/student_providers/selected_assignment_notifier.dart';
import 'package:halqati/provider/token_notifier.dart';

final studentFeedProvider =
AsyncNotifierProvider<StudentFeedNotifier, List<dynamic>?>(
  StudentFeedNotifier.new,
);

class StudentFeedNotifier extends AsyncNotifier<List<dynamic>?> {
  @override
  FutureOr<List<dynamic>?> build() async {
    final tokenAsync = ref.watch(tokenProvider);

    if (tokenAsync.isLoading) return null;

    final token = tokenAsync.value;
    if (token == null || token.isEmpty) return [];

    try {
      return await ref
          .read(eventApiProvider)
          .getStudentFeed(token);
    } catch (e) {
      if (e is UnauthorizedException) {
        await AuthHelper.handleLogout(ref);
      }
      rethrow;
    }
  }

  dynamic getSelectedItem() {
    final String selectedIndex = ref.watch(selectedAssignmentProvider).toString();
    if (!state.hasValue || state.value == null) return null;
    try {
      return state.value![int.tryParse(selectedIndex)??0];
    } catch (_) {
      return null;
    }
  }

  void markAsRead(int assignmentId, int studentId) {
    state = state.whenData((items) {
      if (items == null) return [];

      return items.map((item) {
        // ✅ Only handle Assignment
        if (item is Assignment) {

          if (item.id.toString() != assignmentId.toString()) return item;
          final updatedStudent = item.students[0].copyWith(isRead: true);

          return item.copyWith(
            students: [updatedStudent],
          );
        }

        // ✅ Keep Event untouched
        return item;
      }).toList();
    });
  }


  Future<void> refreshFeed() async {
    ref.invalidateSelf();
  }
}